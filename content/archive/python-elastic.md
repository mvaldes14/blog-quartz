---
title: Twitter Sentiment Analysis with Python & Elasticsearch
date: 2019-05-13
description: Using Elasticsearch to do Sentiment Analysis
status: Complete
tags: 
- automation
- elk
---

Elasticsearch has become part of my daily routine so the more I use it, the more I think of ways of using it outside work so came up with the idea of why not creating my own ingestion with sentiment analysis so that data can be processed and tagged before being indexed into Elastic?.

I know Logstash has already a plugin to ingest data from twitter but since i also wanted to add a bit of polarity to each tweet and also wanted to control the process since I truly don't want to ingest a lot of data as I don't have unlimited storage so i decided to make my own and turns out it was quite simple.

Now to being, the dependencies I used for this were:

1. Elasticsearch 6.5
2. python-elasticsearch
3. twython
4. textblob

Elastic offers 2 libraries to interact with your node, so make sure you pip install [this one](https://elasticsearch-py.readthedocs.io/en/master/).

# Start your ES instance

Now setting an instance could be complicated so i'll just go over some very basic setup, if you want something more ellaborate the elastic.co [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/getting-started.html) is quite good.

1.  Make sure you have java installed.

```bash
java --version
openjdk version "1.8.0_192"
OpenJDK Runtime Environment (build 1.8.0_192-b26)
OpenJDK 64-Bit Server VM (build 25.192-b26, mixed mode)
```

2.  Download Elasticsearch from [here](https://www.elastic.co/downloads). This will be different based on your OS/Distro. Again in my case I went with 6.5 since I run "Linux-Manjaro".
3.  Extract the contents.
4.  Locate and run the binary, it's usually located inside `elasticsearch/bin/elasticsearch`. The process should start and you should see something like this.

```bash
[2018-12-24T07:52:53,670][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [aggs-matrix-stats]
[2018-12-24T07:52:53,670][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [analysis-common]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [ingest-common]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [lang-expression]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [lang-mustache]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [lang-painless]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [mapper-extras]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [parent-join]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [percolator]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [rank-eval]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [reindex]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [repository-url]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [transport-netty4]
[2018-12-24T07:52:53,671][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] loaded module [tribe]
[2018-12-24T07:52:53,672][INFO ][o.e.p.PluginsService     ] [YmQ2k-V] no plugins loaded
[2018-12-24T07:52:57,413][INFO ][o.e.d.DiscoveryModule    ] [YmQ2k-V] using discovery type [zen] and host providers [settings]
[2018-12-24T07:52:58,116][INFO ][o.e.n.Node               ] [YmQ2k-V] initialized
[2018-12-24T07:52:58,116][INFO ][o.e.n.Node               ] [YmQ2k-V] starting ...
[2018-12-24T07:52:58,562][INFO ][o.e.t.TransportService   ] [YmQ2k-V] publish_address {127.0.0.1:9300}, bound_addresses {[::1]:9300}, {127.
0.0.1:9300}
[2018-12-24T07:53:01,689][INFO ][o.e.c.s.MasterService    ] [YmQ2k-V] zen-disco-elected-as-master ([0] nodes joined), reason: new_master {Y
mQ2k-V}{YmQ2k-VPQKGmDK_xcRSQuQ}{yKFFqQ0xQHGmXjNxu89gAQ}{127.0.0.1}{127.0.0.1:9300}
[2018-12-24T07:53:01,696][INFO ][o.e.c.s.ClusterApplierService] [YmQ2k-V] new_master {YmQ2k-V}{YmQ2k-VPQKGmDK_xcRSQuQ}{yKFFqQ0xQHGmXjNxu89g
AQ}{127.0.0.1}{127.0.0.1:9300}, reason: apply cluster state (from master [master {YmQ2k-V}{YmQ2k-VPQKGmDK_xcRSQuQ}{yKFFqQ0xQHGmXjNxu89gAQ}{
127.0.0.1}{127.0.0.1:9300} committed version [1] source [zen-disco-elected-as-master ([0] nodes joined)]])
[2018-12-24T07:53:01,714][INFO ][o.e.h.n.Netty4HttpServerTransport] [YmQ2k-V] publish_address {127.0.0.1:9200}, bound_addresses {[::1]:9200
}, {127.0.0.1:9200}
[2018-12-24T07:53:01,715][INFO ][o.e.n.Node] [YmQ2k-V] started
```

**NOTE:** If you want to run it in the background add parameters `-d` to daemonize it.

Finally test to see if your node is ready by performing a request against your localhost in port 9200 which is the default used by ElasticSearch. In my case I named my node "node-1" and my cluster "home-cluster"

```bash
curl localhost:9200
{
"name" : "node-1",
"cluster_name" : "home-cluster",
"cluster_uuid" : "Ma_eYy0UT1C5b0WwOhQshw",
"version" : {
  "number" : "6.5.4",
  "build_flavor" : "default",
  "build_type" : "tar",
  "build_hash" : "d2ef93d",
  "build_date" : "2018-12-17T21:17:40.758843Z",
  "build_snapshot" : false,
  "lucene_version" : "7.5.0",
  "minimum_wire_compatibility_version" : "5.6.0",
  "minimum_index_compatibility_version" : "5.0.0"
},
  "tagline" : "You Know, for Search"
}
```

5. Ok so now you have your single node cluster set, next step would be to create a "model" for the data you will ingest, again since i don't have unlimited storage or more nodes I will tweak the mapping for all of the indices that get created to just have 1 shard with no replicas. This is an elasticsearch type of deal so if you want to learn more, i would again point you to the documentation or you can ask me (social media stuff at the bottom).

Now i could create the mapping everything i index the data but then again, that's manual stuff which i kind of despise so i went ahead and created a template so that all indices that would match the pattern would adopt the settings.

```json
 "trump_tweets" : {
  "order" : 0,
  "index_patterns" : [
  "trump-*"
  ],
  "settings" : {
  "index" : {
    "number_of_shards" : "1",
    "number_of_replicas" : "0"
  }
  },
  "mappings" : { },
  "aliases" : {
  "trump-data" : { }
  }
}
```

So once you have the mapping defined we are finally ready to push some data using Python!.

# Ingesting data with python-elasticsearch

Alright so the first thing we have to do is acquire some twitter credentials and token so that we can make use of the libraries to retrieve tweets, to get those credentials go [here](https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html).

First thin is to define the connection object that we will use to interact with Elasticsearch, also we will import the whole thing, since we are doing sentiment analysis we of course need those libraries.

In the last portion we tell elasticsearch that if the index called 'trump' does not exist

```python
from textblob import TextBlob
from elasticsearch import Elasticsearch
import uuid
import json
from datetime import datetime

# Elastic Connection
es = Elasticsearch(hosts="localhost")
index_name = 'trump-' + datetime.now().strftime('%Y.%m.%d')
```

Next, we will define the data model used to describe each 'tweet' or event and pass it down to elasticsearch, in here is where we do the sentiment analysis using library 'TextBlob'.

```python
class Tweet(object):
  def __init__(self, username, realname, location, tweet_text, hashtags):
    self.id = str(uuid.uuid4())
    self.timestamp = datetime.utcnow()
    self.username = username
    self.realname = realname
    self.location = location
    self.tweet_text = tweet_text
    self.hashtags = [hash["text"] for hash in hashtags]
    self.sentiment = self.get_sentiment()

  def get_sentiment(self):
    return TextBlob(self.tweet_text).sentiment.polarity

  def push_to_elastic(self):
    es.index(
      index=index_name,
      doc_type="tweets",
      id=self.id,
      body={
          "@timestamp": self.timestamp,
          "user": self.username,
          "realname": self.realname,
          "location": self.location,
          "tweet": self.tweet_text,
          "hashtags": self.hashtags,
          "sentiment": self.sentiment,
        }
    )
  def get_details(self):
    print(self.timestamp, self.username, self.tweet_text, self.hashtags, self.sentiment)
```

Finally we will make use of the client and data objects to start a stream that will push all of the tweets with our added data to the Elasticsearch index so that we can later do some searches and visualizations with it using Kibana.

```python
from twython import TwythonStreamer
from models import Tweet, es
from datetime import datetime

CONSUMER_KEY = "YOURKEYGOESHERE"
CONSUMER_SECRET = "YOURKEYGOESHERE"
AUTH_TOKEN = "YOURKEYGOESHERE"
AUTH_SECRET = "YOURKEYGOESHERE"


class MyStreamer(TwythonStreamer):
  def on_success(self, data):
    try:
      tweets = Tweet(
        username=data["user"]["screen_name"],
        realname=data["user"]["name"],
        location=data["user"]["location"],
        tweet_text=data["text"],
        hashtags=data["entities"]["hashtags"],
      )
      tweets.push_to_elastic()
    except KeyError:
      pass


  def on_error(self, status_code, data):
    print(status_code)
    self.disconnect()
    return False

  def on_timeout(self, data):
    print("Request timed out, try again later")
    self.disconnect()

def start():
  stream = MyStreamer(CONSUMER_KEY, CONSUMER_SECRET, AUTH_TOKEN, AUTH_SECRET)
  stream.statuses.filter(track=["Trump", "trump"])


if __name__ == "__main__":
  start()
```

Now that we have everything ready we can simply run the script and this should start pushing data to our single node cluster.

To validate, you can hit the endpoint 'http://localhost:9200/\_cat/indices?v' and you should get something like.

```sh
health status index                              uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   trump-2019.03.09                   yYHYloR5TEGlenfKjYe4PQ   1   0     139190            0       59mb           59mb
```

In the next part we will start playing around with the data. If you have any questions, hit me up on social media.
