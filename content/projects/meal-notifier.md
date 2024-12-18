---
title: Meal Notifier with Go
date: 2024-05-03
description: Kid's nutrition is important, so let's automate it
status: Complete
tags:
- automation
- random
---
Great teachers on the internet preach that in order to learn a new language effectively, you have to build something with it. Also, those great teachers are pretty much tech Twitter, which can be toxic and polarizing. So take their lessons with a grain of salt.

Anyway, I've been trying to learn Golang for a while, done some courses, taken notes on it, and even got stuck in tutorial hell for some time until the problem to practice the language presented itself.

__What is my kid going to have for lunch/breakfast today?__

As a software engineer, I started the journey to see how to even answer that question, which led me to finding the school site that basically has a calendar with all the options available for kids to pick from and for parents to be aware of their kids' diet... that could've been it... no need to do anything else and move on with my life, but there's no automation or a way for me to get that information delivered every day at specific times. I'm not a fan of logging into something just to get a glimpse of some data.

I almost gave up, but of course, knowing how the web works, I figured, what is feeding this page? Is there some sort of API underneath? If not, maybe I can do some good ol' scraping?

An API was hiding in there after all; I found it by checking the Network tab while loading the page. I found an endpoint that basically feeds the entire site, and you can filter down to specific days or school districts. The endpoint looks something like this

```bash
https://api.mealviewer.com/api/v4/
```
You can then pass specific parameters to filter your specific school from the district and couple calls later you end up with a response that contains a lot of data, things like calories and nutritional information which is pretty nice, but what I'm after is the block that contains what is actually for both: Breakfast and Lunch.

```json
  "id": 620564,
  "calculatedPortionSize": 1.0,
  "object": "foodItem",
  "menu_Name": "Elementary Breakfast",
  "item_Order_Id": 1,
  "block_Name": "Breakfast", // Type of meal
  "block_Id": 1998,
  "block_Type": "menu",
  "menu_Block_Date": "2024-04-29T00:00:00", // When is this meal served
  "location_Id": 13595,
  "imageFileName": "633/1AKM2B0O7ht.png",
  "item_Id": 620564,
  "item_Name": "French Toast Bites", // Informaiton we need
  "nutritionals": [] // could be used if your kid has specific allergies

```

Knowing how the data looks like and what we need from it, we can then start doing some Go!

The design for this mini project is quite easy:
- Query the API filtering down the school and date.
- Parse the response from the API
- Form a new structure on how I want the data to look like
- Print out the end structure

That's pretty much it, yes?. A simple Golang script that does an HTTP request and prints out something...which is a good starting point but of course that doesn't solve the automation and notification portion and since I like to overengineer my life we will also turn this into a Kubernetes cronjob that posts a message to my telegram channel. So we will also need the following:
- Kubernetes Namespace and Cronjob to launch it on a schedule
- Dockerfile to build the image for the script/app
- CICD to upload the image to an image registry (DockerHub)
- Code to include sending data to Telegram
- Secrets to obscure details like my kids school name and the tokens for telegram (Doppler)

# Build stuff time
> TLDR: If you just want to see the finished thing check out the repos [meal-notifier](https://github.com/mvaldes14/meal-notifier) and [k8s-manifest](https://github.com/mvaldes14/k8s-apps/blob/main/cronjobs/meal-notifier.yaml)

So we start by simply building the URL with the parameters needed.

**Note:** on the API you need to pass the date range, so it knows when to pull from and since I only need today's meal information we provide it twice.

```go
today := time.Now().Format("1-2-2006")
baseURL := os.Getenv("BASE_URL")
if !strings.HasPrefix(baseURL, "http") {
	return "URL Not provided"
}

var url = fmt.Sprintf("%s/%s/%s/0", baseURL, today, today)

```

Send the request and parse the response, so it matches a struct. In this case I used online tools that generate a struct out of a JSON. The actual response was huge, so I removed a lot of things that were not needed, so we end up with a pretty slim object/type.

```go
type response struct { // Trimmed down version of the response with just needed fields
    MenuSchedules []struct {
        MenuBlocks []struct {
            BlockName         string `json:"blockName"`
            ScheduledDate     string `json:"scheduledDate"`
            CafeteriaLineList struct {
                Data []struct {
                    Name         string `json:"name"`
                    FoodItemList struct {
                        Data []struct {
                            LocationName string `json:"location_name"`
                            ItemName     string `json:"item_Name"`
                            Description  string `json:"description"`
                        }
                    } 
                }
            } 
        } 
    } 
}
...

req, err := http.Get(url) // Send request
	if err != nil {
		fmt.Println(err)
		return ""
	}

	if req.StatusCode != 200 {
		fmt.Println("Error: ", req.StatusCode)
		return ""
	}

	var response response
	data, err := io.ReadAll(req.Body)

	json.Unmarshal(data, &response) // Parse response using struct above

	defer req.Body.Close()
```

Once we have our response in a Golang struct we can then start the madness and iterate over it, since the API returns a pretty extensive object with a lot of nested lists, several loops were required to get to the information we are after. 
I'm sure there are more efficient and probably better ways to achieve this, but my primitive brain just went with something simple.

```go
for _, menu := range response.MenuSchedules {
		for _, block := range menu.MenuBlocks {
			for _, line := range block.CafeteriaLineList.Data {
				for _, item := range line.FoodItemList.Data {
					if item.LocationName == "CRES- Alternate" {
						continue
					}
					switch block.BlockName {
					case "Breakfast":
						breakfast := meal{
							Type: "Breakfast",
							Item: item.ItemName,
						}
						message.Meals = append(message.Meals, breakfast)
					case "Lunch":
						lunch := meal{
							Type: "Lunch",
							Item: item.ItemName,
						}
						message.Meals = append(message.Meals, lunch)
					}
				}
			}
		}
	}

	var payload string
	payload += fmt.Sprintf("Today is: %s\n", time.Now().Format("2006-01-02"))
	for _, meal := range message.Meals {
		payload += fmt.Sprintf("For %s: %s\n", meal.Type, meal.Item)
	}
```

With the payload built we can simply then just pass this along to another function that sends the message to Telegram.

```go
token := os.Getenv("TELEGRAM_HOMELAB_TOKEN")
chatID := os.Getenv("TELEGRAM_CHAT_ID")

if token == "" || chatID == "" {
	fmt.Println("Missing token or chat id")
	return
}

var url = fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", token)
body, _ := json.Marshal(map[string]string{
	"chat_id": chatID,
	"text":    msg,
})
req, err := http.Post(url, "application/json", bytes.NewBuffer(body))
if err != nil {
	return
}
defer req.Body.Close()
```

That pretty much covers the application.
Like I mentioned, it's a pretty simple get/post request script. This could've been done in bash am I right!?!?!.


# Some Devops'ing?
With the product built we then proceed to make sure this runs on a schedule and that it can pull secrets from my preferred provider [Doppler](https://www.doppler.com/).

First thing we need is to build the container image, which is pretty easy, but we are adding the Doppler CLI on it so when the container boots it can connect to Doppler using a service account token and inject those secrets at.
```dockerfile
FROM golang:1.21.5-alpine

RUN wget -q -t3 'https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key' -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub && \
    echo 'https://packages.doppler.com/public/cli/alpine/any-version/main' | tee -a /etc/apk/repositories && \
    apk add doppler

WORKDIR /app

COPY . /app

RUN go build -o meal-notifier .

ENTRYPOINT ["doppler","run","--","./meal-notifier"]
```

Now that the image can be built, we do some CI/CD to make sure this gets built and published to DockerHub. The action will be pretty simple as it will just install docker, build the image and push it out. Do note your repo will need to have the secrets, so it knows how to connect to the hub.

```yaml
 steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Docker Build and Push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: rorix/meal-notifier:latest
```

The final step is to make this run in Kubernetes, because we like to complicate our life right... this could've been in a cronjob on one of my Homelab machines but NO we like the Kubes!. The manifest will simply generate the namespace and define the cronjob to run and when to do it.

Key thing is that the container needs to know the Doppler service account token, so it can retrieve those secrets, so that token resides within the cluster and gets pulled down by the cronjob.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cronjobs
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: meal-notifier 
  namespace: cronjobs 
spec:
  schedule: "0 7 * * 1-5"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: meal-notifier
            image: rorix/meal-notifier:latest
            env:
            - name: DOPPLER_TOKEN
              valueFrom:
                secretKeyRef:
                  name: cronjob-secrets
                  key: DOPPLER_TOKEN
          restartPolicy: OnFailure
```

With everything said and done, the cronjob will execute and now every Monday through Friday I will have a nice message on Telegram that looks like this:


Notification from Telegram
<img src="https://s3.mvaldes.dev/blog/meal-notification.png" alt="Meal Notification"/>


Cronbjob Execution.
<img src="https://s3.mvaldes.dev/blog/meal-cronjob.png" alt="Meal Cronjob" />

# Conclusion

Learn by doing is the way to go!. And this was my first "real" project using Go so building something so simple took me couple hours just to understand how Go manages things and what methods were the ones I needed to use.
I'm quite happy with how it turned out, and it gave me the fuel needed to trying more things with the language. 

So now I'm waiting for the next "problem" to present itself, so I can smack it with some Go!.

Hope you liked it. 
See ya on the next one. 

Adios 👋