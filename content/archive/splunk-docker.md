---
title: Splunk Quickstart Guide
date: 2020-12-16
description: Not everything is Elasticsearch in this life.
status: Complete
tags: 
- splunk
- container
---

An opportunity came up at work for me to expand my tool set into another logging solution that is quite popular, Splunk.

Known to be a bit expensive cause of the license fees and the model they implement for enterprise solutions I was pretty amazed on what it can do and given the experience, I have with the competition **Elasticsearch**
it was a complete 360 on how I knew data was pushed into the system and leveraged some components and functionality have their similar set of functions comparing it to Elastic...but the main difference to me is how Splunk
manages a **schema on read** which sort of translates to...there are not a lot of fields and you have to create them on your own when searching.

For an actual detailed explanation you can take a peek at the docs, in here we do hands on type of posts.
This demo is made using the free license that allows us to push up to 500 MB to the Splunk instance before incurring into license problems which for most cases should suffice.

## The Setup

Since I'm not a fan of downloading tarballs and setting up a lot of things (users, permissions, service files) I'm going to leverage containers that are packaged with all of the goodies so here's what I'll be using.

```yaml
version: '3'
services:
  splunk:
    image: splunk/splunk
    environment:
      - SPLUNK_START_ARGS=--accept-license
      - SPLUNK_PASSWORD=mysuperstrongadminpassword
    ports:
      - '9997:9997'
      - '8000:8000'
    volumes:
      - /opt/splunk/var:/opt/splunk/var
      - /opt/splunk/etc:/opt/splunk/etc
```

The only thing I've setup was the `/opt/splunk/var` and `/opt/splunk/etc/` mount points in my local server so I could have those configurations easily accessible for me to adjust and tweak.
We also need a port so we can push the data into Splunk via agents called `forwarders` that need a port to connect to so we are mapping `9997` which is the default.
The last piece is that we need a port so that we can connect to our instance via the web UI so we have `8000` mapped as well.

Once you download the big image and it does all of the checks it needs to, hop over to `http://localhost:8000` and you should be greeted by the login page in here you will use username `admin` and the `superstrongpassword` you setup in your environment variables.

## Pushing data in

There are multiple ways to push data into Splunk, you have....

- Agents (heavy and universal forwarders)
- The HEC( HTTP Event Collector)
- TCP & UDP
- Scripts

For this post we are going to leverage the Universal Forwarder agents.

By default the Splunk installation can read files from its local setup meaning it has a forwarder built in but since we have it trapped in a container we can't get much out of it.

The goal in this post is to have the instance read logs from 2 different machines, my local server where I run all of my containers and my gaming rig running windows, for both of these I will use the universal forwarder that you can download
from [Forwarders](https://www.splunk.com/en_us/download/universal-forwarder.html) keep in mind you need to create an account with Splunk.
Make sure you pick the right agent for the OS you will be working with again in my case I've downloaded both tarballs and the Windows MSI.

Before actually pushing data in we have to setup the receiving functionality in Splunk so head over to the Nav Top Menu and go to Settings. In the drop down you should see a "Forwarding and receiving" link,click on that and then go to "Configure receiving".

<img src="https://s3.mvaldes.dev/blog/splunk-1.png" alt="Forwarding" />

Inside that menu you will click on "New Receiving Port" and all that you will need is to define the same port we mapped over in our container `9997`.

<img src="https://s3.mvaldes.dev/blog/splunk-2.png" alt="Receive" />

Now before we get the agents setup we have to do one final but critical step, create the indices that will receive the data, this is something i wasn't fully aware of that in SPLUNK **you need to create the indices FIRST and then setup your agents, the indexes are NOT AUTO-GENERATED unlike Elastic**. Had setup my agents and I couldn't see any data.... couldn't figure it out, suffice to say... wasted couple hours learning this the hard way.

Go to Settings → Indexes and create those Index, in my case I'm going to do one for all of my windows events and one for linux.

<img src="https://s3.mvaldes.dev/blog/splunk-3.png" alt="Index" />

### Now the agents

The installation is windows is pretty straightforward, you click on Next until its done using the default settings. For the configuration of the inputs and outputs we will make use of the CLI.

For installing the agent on linux you simply unpack the tarball and place it somewhere you like, I personally always dump everything out to `/opt`. Same as with above we will configure this agent via the CLI.

These commands work the same regardless of the OS the agent runs on. We will assume your agents are installed in locations:

```sh
- C:\Program Files\SplunkUniversalForwarder
- /opt/splunkforwarder
```

In both cases you can get to the binary by going to the .... bin folder

```bash
# Start the service, you will be asked to setup a user and password for the local agent, remember those credentials
./splunk start --accept-license

# Add the forwarding server that will receive your events, you will need to know the <IP-of-your-host-running-splunk>
./splunk add forward-server <IP>:9997

# Confirm the forward server, you should see something like
./splunk list forward-server
Active forwards:
        192.168.0.22:9997
Configured but inactive forwards:
        None
# To tell it to "monitor" some files, you just pass in your path or filename
./splunk add monitor "/var/log/*" -index linux

# To verify the monitored files and folders
# Splunk monitors itself so you will see a big list of files in here but yours should be there too
./splunk list monitor
   /var/log/*
                /var/log/audit
                /var/log/btmp
                /var/log/btmp.1
                /var/log/fluentd
                /var/log/gssproxy
                /var/log/journal
                /var/log/lastlog
                /var/log/lighttpd
                /var/log/nextcloud
                /var/log/nextcloud/audit.log
                /var/log/old
                /var/log/pacman.log
                /var/log/private
                /var/log/squid
                /var/log/wtmp
```

By default these commands generated a set of files that are CRITICAL to how the agents work.... the `inputs.conf` and the `outputs.conf` which are the list of what it will monitor and where it will send it to. Since we have custom indices we can validate that the files contain the same `stanzas` that we declared in the CLI.

The files are usually located inside the respective `etc/system/local/` folders

```bash
# inputs.conf
[monitor:///var/log/*]
index=linux

# outputs.conf
[tcpout:default-autolb-group]
disabled = false
server = localhost:9997

[tcpout-server://localhost:9997]
```

For windows, most of the relevant things I wanted to monitor reside inside the windows event logs so I manually created the `inputs.conf` with the following stanza. Pretty simple it will read from these 3 facilities and ignore everything older than 3 days and push those into my custom index.

```bash
# windows inputs.conf
[WinEventLog://Application]
index=windows
ignoreOlderThan=3d

[WinEventLog://Security]
index=windows
ignoreOlderThan=3d

[WinEventLog://System]
index=windows
ignoreOlderThan=3d
```

With everything setup we may now restart the agents `./splunk restart` and we should see data in Splunk.

<img src="https://s3.mvaldes.dev/blog/splunk-4.png" alt="Splunk" />

## Conclusion

I hope this post guided you on how the ingestion setup works in Splunk, the multiple components that are involved in the flow and the overall functionality of it all. My next project is going to be pushing my docker logs into Splunk and of course learning the extensive language that Splunk uses to extract, graph and visualize the data. Because remember that unless you create a very specific parsing pattern using sourcetypes you will not see default fields.

If you have any questions or comments, hit me up on twitter, linkedin, etc.
