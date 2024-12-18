---
title: Python Flask in a container
date: 2018-12-07
description: Devcontainers in a nutshell
status: Complete
tags: 
- container
---

**_Make your apps easier to deploy and carry with you_**

I’ve been recently using my work laptop to code while things are calm and I’m waiting for the next fire to pop up (I work in production support). So once i installed everything I needed…. python, git, vscode, nodejs, etc. Realized one big thing, everything works differently in windows and I'm already used to work in Linux OS systems and i cannot just switch the OS in my work laptop cause then the IT guys going to get me fired.

So while looking at solutions to mitigate my situation, decided to force myself to use something new and exciting because it would’ve been easy to just install Vagrant/VirtualBox and spin a machine to do my dev work but where is the fun in that?

### Enter Docker…
In this new IT world where everything is moving towards containers and microservices, thought it would be a good idea to jump on the hype train and learn how to ‘dockerize’ my flask applications. So I watched some videos and tutorials, read some of the documentation and did a test on a dummy application, so here we go.

Install Docker Engine First thing is of course installing Docker, now depending on your OS you can get it one way or another. Unless you have an enterprise need or license, go with the CE versions. Docker install

Create or use your application In my case, most of my applications were either running on my local rasperby pi at home or on heroku so I just decided to create a super simple dummy app that would display a picture and some text.

So once i created a new virtualenv using pipenv, my folder structure looked like this.

    ```python
    .
    ├── Pipfile
    ├── Pipfile.lock
    └── python-flask
        ├── app.py
        ├── requirements.txt
        └── templates
            └── index.html

**app.py**

    ```python
    from flask import Flask, render_template
    import random

    app = Flask(__name__)
    app.config['SECRET_KEY'] = random.randint(1, 100)

    @app.route('/')
    def index():
        return render_template('index.html')

    if __name__ == '__main__':
        app.run(debug=True)

As you can see an incredibly simple app that returns an even simpler ‘index.html’.

**index.html**

    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <style>
            .body {
                background-color: magenta;
                margin: 20px;
                padding: 20px;
            }
            .h1 {
                color: pink;
            }
        </style>
        <title>Document</title>
    </head>
    <body>
        <h1>Docker</h1>
            <p> Container python app </p>
        <hr>
        <img src="http://www.imagefully.com/wp-content/uploads/2015/08/Funny-Cats-Lol-Sup-Bro-Image.jpg" alt="">
    </body>
    </html>

** Create your Dockerfile **

Now, in order for you to interact with the Docker Engine you need to instruct docker how to build your image. An image can be seen as a snapshot of how something should look like including configurations, files, environment variables, etc.

This is the part were I got stuck the most since I had to read what the keywords do and how to interact with them, so if you want the reference for everything, check here.

Will give you a summarized version of what I did for my personal image.

All dockerfiles must either be using an existing base image or using something from scratch.

Since the docker store already contains a bi-zillion images from official repos like Ubuntu, centos, nginx, mysql, etc. There should be no need for you to create something from scratch were you basically build the OS layers and everything. So in my case i went with a very simple Ubuntu image.

This is how you ‘inherit’ or use the base image from the docker store.

    FROM ubuntu:latest

If you want to see all of the images in your system simply run the command docker images. In my case i downloaded and played around postgress as well so my output looked like.

    REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
    docker.io/ubuntu     latest              0458a4468cbc        12 days ago         111.7 MB
    docker.io/postgres   9.6-alpine          7470b931fc2e        4 weeks ago         37.82 MB

As you can see, an ubuntu image is 111.7 MB ONLY!!! - This to me is the beauty of the containers, incredibly light weight and super portable for you to carry around, if we were doing this with a Virtual Machine, we would be talking about gbs of data.

Next command on a typical file are labels, which can contain anything you want, mostly used for metadata.


```
LABEL maintainer="yourname" version="1.0" maintainer_email="youremail@mail.com"
NOTE: Most images still use the deprecated keyword MAINTAINER. Ideally you want to use LABELs instead.
```

Next command is super important as it allows you to specify what you want docker to do while building your image, this is where you typically install or do things on top of base images.

In my case I wanted to install pip and the build-essential bundle so I could run my flask application.

    RUN apt-get update -y && apt-get install -y python-pip python-dev build-essential

Ideally you want to ‘chain’ your commands using ‘&&’ so you reduce the amount of layers it generates.

Once you have everything installed you want to move your application code into the image to be used, so in here based on what I read you can either use COPY or ADD. You might want to read the documentation to see which one to pick but based on this SO post. For basic data moving, either one will work just fine.

    COPY ./python-flask/ /usr/src/app

As most python applications, we requires modules and packages to run things, unless you are using the built-in library of course. But we doing flask, we big boys now so we need to install the packages and its dependencies. We simply add another layer that you will most likely recognize.

    RUN pip install -r /usr/src/app/requirements.txt

We run it at this point since the files were just copied a line above. Remember our requirements.txt was inside the application folder. You can modify the structure and alter the layers but you need to install your requirements at some point.

Once everything is copied and installed we need to tell Docker where we will run our things, so we make use of WORKDIR. It basically sets the directory where you will run your commands from. If you are running a binary that is available in your \$PATH then you may not need this but since i want to make sure my application launches and uses the code we copied above, I force the location.

    WORKDIR /usr/src/app

A key thing with containers is that, they create and spawn the process you tell them to but if you need to interact with it, you need a port to talk to. So in our case, since by default all flask apps run on port 5000. We tell Docker that we want to expose that port in our image so we can actually interact with it.

    EXPOSE 5000

Finally, we run the application.

    CMD ["flask","run","--host=0.0.0.0"]

Do note we are using CMD instead of RUN. This is because we just want this command to be executed as soon as the container is launched, in our case we use the preferred form (called exec) of separating items into a list. You can also use it in a shell form (without the list [] and ”); Again for specifics the documentation does wonders.

**Build your image**
Once we have our files and structure ready, we need to build our image using the Dockerfile we created.

    .
    ├── Dockerfile
    ├── Pipfile
    ├── Pipfile.lock
    └── python-flask
        ├── app.py
        ├── requirements.txt
        └── templates
            └── index.html

To build our image we interact with the docker API, or the CLI for mere mortals like me… By using the following command:

    docker build -t flask .

Things to note. -t TAG Name to use for your image, in my case I’m saying flask so its easy to remember. . With the dot we specify that we want to build using the Dockerfile available in our current location, if you want to use the file from a different place just specify the path.

Once the process completes, if you re-run docker images you should see a new image in your repository.

    REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
    flask                latest              5394dbc7f0eb        23 hours ago        424.6 MB
    docker.io/ubuntu     latest              0458a4468cbc        12 days ago         111.7 MB
    docker.io/postgres   9.6-alpine          7470b931fc2e        4 weeks ago         37.82 MB

As you can see, our image increased quite a bit, but even with that size it can be up and running in seconds. So remember, the more you install and add to it, the bigger it cause, duh logic right?

**Run your image**
If you made it this far, good for you mate. We are almost done. To run our image we again interact with the CLI but in here we need to add some specific parameters to tell it where to put our port and give it a name.

    docker run -d \
    -p 80:5000 \
    --name flaskapp \
    -e FLASK_APP='app.py' \
    flask

The above command should give you a container id, validate it is actually running by doing docker ps. Additionally you can see the usual flask logs by running docker logs <IMAGENAME>.

Since we passed the --name parameter, we just do docker logs flaskapp. And we get the following.

    * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
    24.28.147.10 - - [14/Feb/2018 17:00:43] "GET / HTTP/1.1" 200 -

It is very important that the host is ‘0.0.0.0’ otherwise you will not be able to access it from the outside. If you want to know why, check out this link.

Finally, if we hit the IP where the docker image is running, we should get our flask application. Questions? Concerns? Was this cool?

Let me know in the section below. Next time we will use the image to do live testing in our code.

Cheers!
