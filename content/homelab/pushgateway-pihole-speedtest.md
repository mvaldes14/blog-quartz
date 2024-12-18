---
title: Pihole and ISP Metrics in Prometheus
date: 2021-01-25
description: Track your ISP Speeds and visualize them with Prometheus
status: Complete
tags: 
- automation
- homelab
---

In a previous [post](https:/mvaldes.dev/speedtest-kibana.html) I show cased how you could start collecting some of the metrics that scripts like `speedtest` can dump out and you can leverage that data by ingesting into an Elasticseach cluster so you can later visualize in Kibana dashboards and while that is super nice, the more and more I keep playing with Time Series Databases the more I start to think that full blown logging systems like Elastic and Splunk are simply an overkill for simple numerical metrics like values at specific points in time. Not to stay the tools can't handle it but its like using a jackhammer to hang a picture in your wall.

Out of all the TSDBs I've played with, the one I enjoy the most is Prometheus. It's simple to use, light weight, can be run in a container and it has a lot of mechanisms to push data into it. Right now my current instance is collecting metrics from my docker daemon runnning all of the containers in swarm mode, my system metrics from 2 computers and my reliable Raspberry Pi and with a Grafana instance on top of it I have visibility on everything my small homelab might need.

## The "Problem"

You might ask, well why move what is already working on Elastic to a new system?. Well I was bored and also had the need to add some custom "metrics" I wanted to keep track off and wanted to use an actual TSDB for some actual metrics so here's the problems im trying to solve. Adding these to something like Elastic would've been easy as well but the need to try something new won me over. Here's what I intend to add.

1. My Piholes for some reason stop responding to DNS queries after some point, I need to sit down and figure out why but meanwhile doing a `restartdns` works, so it's scheduled in a cron job but I would like to know the number of resets i've done on each.
2. The number of clients on each Pihole tends to change over time so I would like to visualize which one is taking more traffic.
3. The number of block elements on each pihole should be in sync but since there's no clustering availble yet, I have to manually keep them alligned so if the number of block pages is not the same on each I can easily see it in a graph.
4. Finally, move all of the ISP metrics I was collecting before and pushing into elastic will now go to Prometheus (download/upload speed, lattency, etc.)

## The "Solution"

One of the downsides is that Prometheus doesn't directly let you POST data into it with something like `curl` cause it works on a "pull model" meaning it only reads from external, it doesnt actually receive anything from the ouside unlike other tools like ES or Splunk, you could potentially use a client library to collect said metrics and generate an endpoint Prometheus can read.... but I am not that bored..... so we have to leverage a separate component called "PushGateway" that will basically work as a sink to collect everything you push into it and then your Prometheus instance will scrape all of the metrics it finds and store them into the TSDB. In my case since everything I run is "dockerized" I will use the container version of it.

The full documentation on how to instrument and push data into it can be found here [https://github.com/prometheus/pushgateway](https://github.com/prometheus/pushgateway)

So let's start the gateway.

```bash
docker run -d -p 9091:9091 prom/pushgateway
```

With that listening you can navigate to [http://localhost:9091](http://localhost:9091) and you should see a basic UI.

When you push the data you have to be mindful on how you name it and what other properties you pass to it like instance or labels if applicable.

All of your metrics must follow the pattern `url:port/metrics/job/<job_name>/instance/<instance_name>`

Now we will do a very simple sets of bash scripts that will be running via cron or systemd timers to basically collect data and then push those metrics into the gateway. First one will restart the DNS service and increase the counter.

```bash
#!/bin/sh
# Set variables
JOB_NAME=pihole
INSTANCE_NAME=pi

# Execute Action
pihole restartdns

# Post to Gateway
cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/$JOB_NAME/instance/$INSTANCE_NAME
  pihole_reset_counter 1
EOF
```

To Grab the number of current blocked domains in each pihole, we could interact with the sqlite3 database that ships with the tool and we will simply query the gravity table that holds all domains and export a base count, save that on a variable and push to the gateway....but since the tool also comes with a nice way to export a lot of the good stats for people that plug in LCDs to their Raspberry Pi we will explode that....who wants to do SQL anyway.... `sqlite3 /etc/pihole/gravity.db "select count(*) from gravity"`. For "parsing" the data exported in JSON we will also use `jq`.

```bash
#!/bin/sh
# Set variables
JOB_NAME=pihole
INSTANCE_NAME=pi

# Execute Action
PIHOLE_STATS=$(pihole -c -j)
PIHOLE_DOMAINS_BLOCKED=$(echo $PIHOLE_STATS | jq .domains_being_blocked)
PIHOLE_DNS_QUERIES=$(echo $PIHOLE_STATS | jq .dns_queries_today)
PIHOLE_BLOCKED_QUERIES=$(echo $PIHOLE_STATS | jq .ads_blocked_today)

# Post to Gateway
cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/$JOB_NAME/instance/$INSTANCE_NAME
    pihole_blocked_domains $PIHOLE_DOMAINS_BLOCKED
    pihole_dns_queries $PIHOLE_DNS_QUERIES
    pihole_blocked_queries $PIHOLE_BLOCKED_QUERIES
EOF
```

Finally for the ISP metrics I will reuse the speedtest-cli to output the data needed in JSON and parse it with `jq`. Quite simple right?.

```bash
#!/bin/sh
# Set variables
JOB_NAME=speedtest
INSTANCE_NAME=pi

# Execute Action
SPEEDTEST_DATA=$(speedtest --json --single)
SPEEDTEST_PING=$(echo $SPEEDTEST_DATA | jq .ping)
SPEEDTEST_LATENCY=$(echo $SPEEDTEST_DATA | jq .server.latency)
SPEEDTEST_UPLOAD=$(echo $SPEEDTEST_DATA | jq .download)
SPEEDTEST_DOWNLOAD=$(echo $SPEEDTEST_DATA | jq .upload)

# Post to Gateway
cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/$JOB_NAME/instance/$INSTANCE_NAME
    speedtest_ping $SPEEDTEST_PING
    speedtest_latency $SPEEDTEST_LATENCY
    speedtest_upload $SPEEDTEST_UPLOAD
    speedtest_download $SPEEDTEST_DOWNLOAD
EOF
```

When these scripts are executed manually or by systemd/cron you should now see your metrics show up in the pushgateway UI. All that is left is to configure your Prometheus instance to scrape the Pushgateway... if you are curious you can see the metrics in http://localhost:9091/metrics.

Here's how mine look for the one test host...the idea is to copy the same set of scripts to my machines running pihole and just modify the variables as needed to use a different instance name.

<img src="https://s3.mvaldes.dev/blog/pushgateway.png" alt="Prometheus pushgateway" />

**NOTE**: The pushgateway is ideal for short dumb things like this, in a PROD environment you might want to consider using something else since this becomes a single point of failure as the documentation says so only use it for fooling around like me or consult with some professionals with more experience using it.

## Conclusion

Prometheus is a great TSDB and it's super simple to run, quite popular and the default time series database for big projects like Kubernetes.... not to mention it's a "graduated" project from the CNCF. You can pair it with something like Grafana and you can go crazy with the amount of things you can create. Again, for PROD usage you might want to have multiple instances and in federated mode for that High Availability, but since these posts are mostly me playing around with tech you can replicate the single node point of failure model and it will work great until it doesn't.

I do wish that Prometheus would let you push data in directly but that completely breaks the pull model so we will have to live with the pushgateway and the multiple client libraries that emulate a mini webserver that your Prometheus instance can scrape.

At the end of this I've tackled all of the "problems" I created for myself and the next step is getting those cool dashboards....On my next spring of boredoom I will generate those in Grafana and share them in the post.
