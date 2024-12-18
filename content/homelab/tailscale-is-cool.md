---
title: Tailscale is pretty cool 
date: 2024-07-21
description: I can access my homelab anywhere, hbu?
status: complete
tags: 
- homelab
---

Big part of owning a Homelab is running a ton of services for myself or the family, some of which can be and should be [accessed via the internet](https://mvaldes.dev/blog/cloudflare-tunnels/) but some of them are private so, I'd like to still figure out a way to get to them without exposing or doing weird reverse proxy magic to filter requests/headers.

I eventually discovered Wireguard, and it was the perfect solution, took me couple minutes to set up on a machine, laptop and my phone, with one caveat __a port had to be exposed__ within my router (port 51820) and suddenly everything local was available on my phone or on my personal laptop while sitting at a coffee shop drinking Chai tea like a total chad; Life was good.

Until someone on a podcast which I can't quite remember anymore, mentioned Tailscale... shrugged it off as my solution was working so why change. Then I saw/heard about it over and over on the r/homelab sub-reddit, so curiosity was peaked and as someone that like to tinker a lot I decided to just give it a try, worst case scenario I have my good ol' reliable Wireguard setup in a compose file to re-apply in seconds right?.

Suffice to say I was impressed with it. It's like Wireguard but without the exposed port and a better UI/App.

<img src="https://c.tenor.com/N5RUSETuDaYAAAAC/hugh-jackman.gif" alt="mind blown" />

Twenty minutes later I had the exact same setup on my 3 devices, everything was working as intended even my local DNS which was a bit of a hassle to figure out on Wireguard natively since those local records reside on my Pi-hole, which btw [you need to set up ASAP!.](https://mvaldes.dev/blog/pihole-is-awesome/)

Now since Tailscale is a paid product of course it has some extra features that allow you to expose routes, a service/CLI that gives you specifics on traffic and clients, split tunneling and user management, etc. **Don't want this to become an AD for them (not paid or sponsored in any way).**

So to conclude, it is a great product, and it uses the same technology deep down (wireguard). 
 It keeps getting updates and features that most of us can leverage without paying a dime for your homelab or small network. The Android App just got a new UI which is beautiful and easy to automate with something like Tasker, having the VPN turn on as soon as I leave my Wi-Fi is just magic.

Would highly recommend giving it a shot, I believe there's a fork on it that is FOSS, so maybe that's more your cup of tea - https://github.com/juanfont/headscale.

>The networking and how to access services in your Homelab is one of the most complicated thing unless you have deep expertise on the subject, so I'm grateful that we have products that facilitate the access.

Anyway, back to some more homelab-ing. Hope this helps you reach into your network easier!.

Adios 👋
