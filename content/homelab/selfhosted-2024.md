---
title: Self Hosted in 2024
date:  2024-03-25
description: An update on my journey for 2024
status: Complete
tags: 
- homelab
---

It's been 4 years since the self-hosted adventure began and it gets bigger and weirder as seasons come and go. What started with a single Dell refurbished machine (which i still use) to run certain services back in [2020](https://mvaldes.dev/blog/docker-home-setup/) has now evolved into an actual mini rack with some serious network devices and more machines. So lets see what changed sine my last post back in [2022](https://mvaldes.dev/blog/selfhosted-2022)

## An Actual Rack Arrived...
Bought a home in the crazy economy.... it was a wild ride but we are pretty happy with what we got, which meant that I no longer had to keep everything in the closet, this was a big change at a personal level but also on my self-hosting cause that meant i could actually get a rack to put everything that I owned which back then was still 1 Dell Machine SFF, 1 Dell 3080 and my Raspberry Pi. Also by having more space meant i needed to think seriously how I wanted my networking to look like. 

Originally I thought a big Access Point connected to the router was going to be sufficient but having 3 levels and 20+ devices it wasn't going to perform or scale well. So i went all in and acquired couple Unifi devices:

- Dream Machine => Acts as a router and controller for other Unifi devices, love the fact it has way more features that lets me see whats going on in my network. Additionally it offers WIFI to the basement level.
- Switch 60W POE => This is when i learned that some devices could be powered by an actual Ethernet cable and luckily for me the home already had Ethernet CAT5 cables all around so i just needed to patch the terminals and off it goes!. This is the critical piece that lets me connect all of my wired devices, like the actual machines that compose the services I run.
- Access Point HD => Provides WIFI at an extended range, powered by POE and placed in the mid level, this single device connects 15+ devices on it own.
- In-Wall Access Point HD => This was a weird addition since I wanted my office to be wired in so i needed to find a way to provide 2-3 Ethernet connectors for my work/personal computers as well as the Playstation for better performance. So it was placed at the top level in the home. This one also provides WIFI so i had all 3 levels covered.
- Flex Switch Mini => A single 4 port switch powered by POE that lets me connect the TV as well as other devices behind our main entertainment area.

This is how it looked it early on

<img src="https://s3.mvaldes.dev/blog/homelab.jpeg" alt="homelab" />

## The servers had babies
With the networking ready now I just needed to add more juice to the whole setup. A local Youtuber who makes a ton of awesome videos about self-hosting [TechoTim](https://techno-tim.github.io/) was getting rid of an Intel NUC and I was lucky enough to be the first one to respond so I got a free powerful mini PC, many appreciations to him for being so kind.

Next step was to solve a very simple problem, none of my machines were powerful enough to do video decode/encode (besides my main rig with a 3080) but that one isn't on 24/7 so the next goal was to find a small machine that had enough processing power to allow me to encode media files on the fly. After much reading the solution was pretty simple, find a SFF (small form factor) computer that had an Intel processor 7th Gen or above. So  after checking my favorite subreddits (r/hardwareswap & r/homelabsales) someone was selling an HP Gen4 machine with an intel 8th gen and 32GB RAM. 

The Homelab was ready. We scaled from 2 to 4 machines + raspberry. So my computing power was ready for the workloads I had in mind.

## Services found a new home
Previously everything I ran was done via docker since it was way easier back then an also my Kubernetes knowledge was pretty limited, so with that in mind in late 2023 I made the jump and deleted everything running under docker (had all of the manifests backed up just in case) which at the time was around 20 stacks with 4X containers all the way from monitoring workloads like Prometheus  + Grafana + Elasticsearch all the way into Nextcloud and Photoprism to replace things I've previously payed for. You can read more on what i ran back then [here](https://mvaldes.dev/blog/selfhosted-2022/)

Since theres no better way to learn than doing I've embarked on the Kubernetes path and started to build everything up again by generating the manifests that were basically composed of a deployment + service. Another big addition is that I fully embraced the GitOps flow so everything was being managed by FluxCD so it was a bit complicated at first to learn a brand new tool on top of a new container runtime and workflow, but it was worth the frustration as I now see the benefits of using this paradigm.

My deployments are now fully automated and in case I ever need to rebuild my entire Homelab all I would need is FluxCD to manage everything for me since all of the manifests now reside in a [Github Repo](https://github.com/mvaldes14/k8s-apps/) .

## New stuff I'm running
With everything automated and ready... the self-hosting bug keeps increasing and ever time I see a new service pop up over in Reddit I have to try it. With the new workflow I can cook up a deployment + service and hook it up to my Cloudflared tunnel running within K8s and I can get a new service running in minutes.

Some new service I've found interesting:

- Windmill => Using it to build and automate some things I used to run in Cronjobs (scrapers mostly)
- Umami => Analytics for this blog you are reading on
- Shlink => Generate links and track them
- Excalidraw => Well... to draw things and I get to host it

Also worth mentioning some stuff I'm __NO__ longer running:

- Wikijs => Fully replaced it with Obsidian
- Gitea => Migrated over to Github to make use of GHA - I do plan to self host my own runners.
- Wallabag => Obsidian
- Minio => Cloudflare R2 - Minio was good but a pain to manage so its one of those i'd rather pay for.
- Fileflows => I no longer have to worry about formats and encodings since i can do those on the fly without constant buffering

## Future 
In the near future I would like to improve the following:
- My backing up strategies for the setup as well as the data, the NAS had a faulty disk sometime in 2023 and it took me awhile to recover from it.
- Balance the workloads, some nodes run more container due to the nature of some of the services so i need to make those more resilient.
- Create VLANs so IoT and other type of devices do not access my entire network
- Make sure my external hosted services are secure with proper authentication so i no longer have to depend on keeping things internal... sometimes i need access to something on the go
- Run my own LLM so I no longer have to use ChatGPT
- Maybe a 1U server so i know what it feels like to run an actual server and not just small computers

That's pretty much it, a lot of things changed over the course of 2023 and with 2024 just starting the Self Hosted Journey continues strong.

Hope you enjoyed the update, see ya next time!

Adios 👋


