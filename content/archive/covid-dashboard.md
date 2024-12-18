---
title: COVID Data in Elasticsearch & Kibana
date: 2020-03-18
description: A little something to showcase what you can do with data and Elastic.
status: Complete
tags: 
- elk
---

So as most people I've been stuck at home so it gave me some extra time to tinker around the dataset on the excellent dashboard by [Johns Hopkins CSSE](https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6) you should check that out if you haven't already, it's quite popular. Anyways found out that they publish all of the data behind the dashboard to their [Github]([https://github.com/CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19)) so wrote a quick script to pull the csv files for March, transform the data via Logstash and push it into my local Elasticsearch instance.

## Getting and formatting data

### Pulling data

With the help of the python `requests` library it was simple to pull the data for each day and just dump it into a file so that i could later tweak it.

```python
def get_files(day):
    # Downloads the files from the REPO and places them in the data/raw folder
    r = requests.get(f"https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/{day}.csv")
    file = r.text
    with open(f'./data/raw/{day}-raw.csv','w') as infile:
        for line in file:
            infile.write(line)
```

### Formatting the data

While reviewing the csv data, I noticed that there were "gaps" in between lines for some records, mostly missing states or province so I just read each line and if the province was missing, I copied whatever the line had for Country.

<img src="https://s3.mvaldes.dev/blog/covid-github.png" alt="covid-github-image" />

Quite simple to do with the csv DictReader function.

```python
def format_files(day):
    # Swaps the column order and fills out missing data for countries and states
    with open(f'./data/raw/{day}-raw.csv', encoding="utf-8-sig") as infile, open(f'./data/{day}.csv', 'w') as outfile:
        reader = csv.DictReader(infile)
        headers = ["Country/Region","Province/State","Last Update","Confirmed","Deaths","Recovered","Latitude","Longitude"]
        writer = csv.DictWriter(outfile,fieldnames=headers)
        writer.writeheader()
        for line in reader:
            # Add Country if it doesn't exist
            if not line["Province/State"]:
               line["Province/State"] = line["Country/Region"]
            writer.writerow(line)
```

With the columns swapped and consistent, I had something nice and manageable.

```bash
Country/Region,Province/State,LastUpdate,Confirmed,Deaths,Recovered,Latitude,Longitude
China,Hubei,2020-03-17T11:53:10,67799,3111,56003,30.9756,112.2707
Italy,Italy,2020-03-17T18:33:02,31506,2503,2941,41.8719,12.5674
Iran,Iran,2020-03-17T15:13:09,16169,988,5389,32.4279,53.6880
Spain,Spain,2020-03-17T20:53:02,11748,533,1028,40.4637,-3.7492
```

### Pushing the data to Elasticsearch

There are multiple ways to push data into an Elasticsearch instance, in previous posts I've done it with the python library but I had a Logstash instance up and running so figured it was easier to use it to read all csv files in my desired location, run it through some of the filters and push it into the cluster for me if you are familiar with how Logstash work you can skip the breakdown.

**ELI5 Logstash - Tool used to transform data, it basically consists of 3 blocks. An input to read data from. A filter to transform or alter the data. An output to send the transformed data to.**

First, we have to tell Logstash what we want to read since we had static files all I had to do was use the file module, all it requires is a path to read from. To prevent it from reading the files over and over it employs a "tracker" that keeps a record of which files were read up until what position. Filebeat does exactly the same and it keeps an internal registry.

```json
input {
file {
  path => ["/home/<user>/projects/covid-dashboard/data/*.csv"]
  start_position => "beginning"
  tags => ['covid','dataset']
  sincedb_path => ["/home/<user>/projects/covid-dashboard/tracker"]
}
}

```

Next up we have to run every single record from each file through a series of filters, from decoding to changing the type of data so it can be used in Elasticsearch.

```json
filter {
  csv {
   columns => ["Country","State","LastUpdate","Confirmed","Deaths","Recovered","Latitude","Longitude"]
   skip_header => true
   convert => {
      "Confirmed" => "integer"
      "Deaths" => "integer"
      "LastUpdate" => "date_time"
      "Recovered" => "integer"
      "Longitude" => "float"
      "Latitude" => "float"
    }
  }
  mutate {
    rename => {
      "Longitude" => "[Location][lon]"
      "Latitude"  => "[Location][lat]"
    }
    remove_field => ["message","host","path","@timestamp","@version"]
  }
}
```

The CSV block simply decodes each line and turns all of the records into Key-Value pairs, then uses the custom headers I wanted to name those keys. The second part turns some of the fields into integers and dates, I do want to point out that this didn't work 100% of the time so I had to do a workaround at Elasticsearch which will be posted in here as well.
The mutate block creates a "geo_point" object that is a nested object that contains a latitude and longitude. It also removes some fields I didn't feel were needed.

```json
output {
  elasticsearch {
      hosts => 'http://localhost:9200'
      index => 'covid'
  }
}
```

Finally, we push out the data to Elasticsearch to an index called "covid".

### Adjust the data in Elasticsearch

As mentioned above, I kept running into issues where some records could not be indexed cause of data type mismatch so after trying for couple hours ended up forcing Elasticsearch to do what I wanted by creating the mapping directly and applying it to the "covid" index. Templates are an Elasticsearch concept that's incredibly powerful and everyone using it should know about it.

My template ends up looking like...

```json
PUT _template/covid
{
  "order": 0,
  "index_patterns": [
    "covid"
  ],
  "settings": {
    "number_of_replicas":0
  },
  "mappings": {
    "properties":{
      "Location": {
        "type": "geo_point"
      },
      "Confirmed":{
        "type": "double"
      },
      "Deaths": {
        "type": "double"
      },
      "LastUpdate": {
        "type": "date"
      },
      "Recovered": {
        "type": "double"
      }
    }
  }
}
```

As you can see I'm merely indicating how the data should look like in terms of the types.

With that in place, it was time to run Logstash and start pushing all 3k+ records, each record ended up looking like.

```json
"_index" : "covid",
"_type" : "_doc",
"_id" : "9O8I73ABTHN1r9G_vStK",
"_score" : 1.0,
"_source" : {
  "Confirmed" : 990,
  "Recovered" : 917,
  "State" : "Anhui",
  "Deaths" : 6,
  "LastUpdate" : "2020-03-02T15:03:23",
  "tags" : [
    "covid",
    "dataset"
  ],
  "Country" : "Mainland China",
  "Location" : {
    "lat" : 31.8257,
    "lon" : 117.2264
  }

```

## Exploring the data

With all of March records so far we can now start exploring the data, in my case I consume things visually so the first thing I did was to start plotting.
I was curious to see how the number of confirmed cases spike in Italy so why not put it in a line chart?. It took off incredibly fast.

<img src="https://s3.mvaldes.dev/blog/covid-italy.png" alt="covid italy" />

I know that most of the casualties occurred in Washington State so the data in a heatmap.

<img src="https://s3.mvaldes.dev/blog/covid-deaths.png" alt="covid deaths" />

Finally, since we have coordinate we could, in theory, replicate some of the dashboards from Johns Hopkins, I'm aware the data needs tweaking to fully be a copy but this sort of gives us an idea.

<img src="https://s3.mvaldes.dev/blog/covid-map.png" alt="covid map" />

With all records, you can explore further and ask all sorts of questions on which states have more cases, which ones are "safe" or quiet. If you are smart you could, use the data to start predicting how the numbers will look like in the coming weeks.

# Conclusion

As always, hoped this kept you busy for a bit, I know it took me a couple hours to bootstrap this whole thing and play with the data/script.

If you have any questions reach out on social media - the repo for everything in this post can be found in [Github](https://github.com/mvaldes14/blog-posts/tree/master/covid-dashboard-elastic)

One last thing... **Stay at home folks and tend to your families, don't be a dick.**
