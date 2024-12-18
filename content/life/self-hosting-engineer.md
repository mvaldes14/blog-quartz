---
title: Why Self-Hosting made me a better engineer
date: 2024-10-30
description: Why I'm potentially better than you homie
status: Complete
tags: 
- career
---

It is a **fact** that people who are passionate about a topic or subject tend to know more or do better at said topics, so in the case of Software Engineers you probably have run into couple different types of engineers, which in my humble opinion (__based on working in the industry for 12 years now__); These are the 3 big "types":

1. The guy who studied CS since it paid good and just work the 9-5. Extra hours probably spent touching grass.
2. The guy who went to CS because he just loves and is passionate about code and everything around it. Most likely works and maintains some open source projects on their downtime. Spends his time arguing over a language or framework on X or Twitter.
3. The self-taught who ended up in tech and comes from an unrelated tech background (nurse, musician, etc.) and is obsessed with it and somehow turns his entire personality and life into tech. Some are crazy enough that build an entire data center in the basement or closet. 

That being said I'd consider myself type 3 as I never did CS at school and everything I know comes from experience and passion.

Some of my big learning experiences that make me stand out vs other engineers at work are the following:

__NOTE:__ This is of course very Ops based, since that's where I started my career in tech.

1. Had to learn an amazing amount of information in order to even get the Homelab usable, from installing the OS to setting up the additional drives and mount points... Setting up a secure SSH configuration, users and credentials, permissions on files, etc.
2. Setting up the entire Networking, this one was huge for me as it helped me a TON to grasps concepts of DNS, TCP, iptables, ports/firewalls, etc. This one skill has made me surpass a lot of my fellow engineers at work, understanding how things are connected and work just changes your perspective. Suddenly everything clicks in your head.
3. Installing things, which at first were done manually but once you start adding more machines or services the manual steps become boring, repetitive and error-prone, we are humans, so we tend to screw those up. So tools like Ansible or Chef stated to appeal to me, so my machines could have the exact same configuration over and over.
4. Containers disrupted my entire way of thinking and running things, so I learned how Docker works and how I could customize my own images and services. This got worse when my Homelab expanded, so I needed to run more containers in the machines so my good ol' network knowledge was useful at understand how those bridges were formed between nodes.
5. Eventually the hot thing was Kubernetes, the migration was painful and full of new concepts and way of doing things, but I feel comfortable now transforming any docker-compose with whatever number of services and containers into Kubernetes manifests. 
6. With the complexity of the manifests tools like Helm Charts or Kustomize became another skill I had to learn, this one was somewhat easy since its just abstractions over manifests.
7. Storage became important so a NAS was acquired and with my knowledge it was easy to set up and start generating some Volume Claims for my own needs.
9. Network went from a basic Netgear router to a full blow installation consisting of:
	1. Unifi Dream Machine
	2. Unifi PoE Switches
	3. Unifi Wi-Fi Access Points
    These devices introduced me into the work of proper networking where you have control over DNS, VLANs, Firewall Policies and actual useful telemetry of what is going on in the network. This part was also the most expensive one so far as those devices aren't exactly cheap.
10. As my workloads became part of the entire family routine without them knowing, things needed to become accessible from in and outside our home. This is when things like Tailscale and Cloudflare tunnels became important.
11. Everything that I paid for became a service I could self-host within my lab so the more things I ran, having availability and good monitoring became critical. To point out it's what I do at work so, this became an excellent playground for me to test different technologies without causing outages.
    - This is probably the main reason why this whole thing started, I wanted a safe environment to test and break without disrupting anyone but myself.
12. Having the playground enabled me to learn how things are built; I started to learn coding and doing the usual dumb apps, turning them into containers and finally deploying them. Great way to see the full deployment lifecycle, nowadays people rely on other engineers or services to do this which is OK, not everyone needs to learn the tech and master it, but it's somewhat important to know what's going on behind the scenes IMO.

Again these are very Ops based which is funny because I built this entire thing to allow myself to learn to code and deploy somewhere end to end, Devops some people call it. That was the original motivation, not building and running on my local machine something that I could rely on or use outside my personal computer, from a little Raspberry Pi running a dumb container and a DNS server to an entire rack with couple machines and enterprise grade network devices.

Now this is an overkill and probably steered into a non so coding arc, but I've found that is what I'm passionate about, systems and how to set them up, figuring out how to configure software on them and make it reliable and easy to monitor effectively. 

Hopefully this helps someone realize that not everything in Software Engineering is coding and being on top of the latest language or framework. Without the infra and people running it even on cloud it all becomes pointless.
Yes even those serverless functions require servers my dudes LOL.

See you on the next one.
Adios 👋


