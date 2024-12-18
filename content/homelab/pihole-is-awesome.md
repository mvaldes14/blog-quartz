---
title: Pihole is pure awesomeness
date: 2020-08-26
description: Why are you not running PiHole in your own network?
status: Complete
tags: 
- homelab
---

Its been months ever since I setup my pihole and I never noticed how much it helps reduce the number of ads and spam I used to see in the webpages until one day the SD card on my raspberry pi was at 100% so everything running in there stopped responding and I never noticed it.... dont be like me and monitor your devices, anyways I started seeing a bunch of pop ups, modals and ads everywhere... That's when I realized once again how much everyone needs a pihole in their Network and also how infected the internet is... of just so much random stuff that tracks you and serves trash.

So figured since I ended up adding a second pihole to my network as a contingency in case the main one runs into issues again I should tell you how awesome the pihole is and why you need one.

The concept of a pihole is quite simple, to block all DNS requests to known malicious and ad provider endpoints, giving you virtually an ad free and safe browsing experience. This is accomplished by turning a device (machine/vm/container) into a DNS server and pointing all your devices to use it as an upstream.

One thing to note is that there are certain sites like YouTube that basically inject the ad into the video feed so blocking it might effectively block you from watching videos so do keep that in mind if your sole purpose was to stop YouTube from serving you ads, this won't work. A shame but FYI.

Another fantastic thing of this project is that the ad lists are maintained by the community so if you notice that a device of yours is doing some extraneous calls and block it you can contribute that domain for everyone to benefit. Trust me once you have a pihole running and you review your traffic from your devices you will notice how much certain things like smart TVs and WiFi cameras make requests every couple minutes or seconds to weird domains.

Easier to show you the benefits, like a good ol' before and after type of deal...

<img src="https://s3.mvaldes.dev/blog/pihole-before.png" alt="Site before pihole" />

Aaaaaaand they're gone.

<img src="https://s3.mvaldes.dev/blog/pihole-after.png" alt="Site after pihole" />

So you are convinced how do you get started, you ask?. Well following the installation depending on the device you want to run it on.

1. Lazy one line installer

```jsx
curl -sSL https://install.pi-hole.net | bash
```

2. Via docker-compose, in my case I do not use my pihole as DHCP but you can do that if you want to.

```jsx
version: "3"

# More info at https://github.com/pi-hole/docker-pi-hole/ and https://docs.pi-hole.net/
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      TZ: 'America/Chicago'
      # WEBPASSWORD: 'set a secure password here or it will be random'
    # Volumes store your data between container upgrades
    volumes:
      - './etc-pihole/:/etc/pihole/'
      - './etc-dnsmasq.d/:/etc/dnsmasq.d/'PN
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
```

With the package or container running, you can visit the web interface at port 80, you should see something like this.

<img src="https://s3.mvaldes.dev/blog/pihole-panel.png" alt="Pihole panel" />

Now its time to send all of your DNS traffic to the pihole, the easiest way is to tell your router to send all traffic to the IP of the machine/device running the service but I've found that most of the times the actual computers in your network might not want to really send the traffic via pihole so its easier to force them.

If you have couple UNIX machines simply modify your `/etc/resolv/conf` and add the nameserver

```jsx
# /etc/resolv.conf
nameserver <ip-device-or-container>
```

On windows you have to do it using the ipv4 settings in the network panel as shown below.

<img src="https://s3.mvaldes.dev/blog/pihole-dns-setup.png" alt="pihole dns setup" />

If everything is done right you should see something similar to mine that indicates that most of the devices are sending traffic to the PiHole, a quick way to ensure it's really working is to visit any site you want and see if that domain appears in your log. So if I visit my own blog I'd end up seeing this.

<img src="https://s3.mvaldes.dev/blog/pihole-test.png" alt="pihole-test" />

The final and fun part is adding domains you want to block to your PiHole, so inside your admin panel go to `Group Management > Adlists` and start adding away, one great place to get lists is reddit or this [site](<[https://firebog.net/](https://firebog.net/)>). Do not forget to update your settings after adding some lists by going to `Tools > Update Gravity` which effectively reads those Adlists and adds them to your local PiHole. It is recommended you update your lists frequently in case the owners or maintainers add more stuff to it. I'm quite happy with mine that contains 860K domains and I rarely see issues while loading pages with those.

_BONUS_ : If you ever want to mess around with your family go ahead and block facebook and instagram, let me know how that played out for you.

Anyways, hope this all made sense, if not please feel free to tell me why this sucked on my social media that you can find down below. See ya next time!
