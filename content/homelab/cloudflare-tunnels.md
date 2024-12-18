---
title: Cloudflare Tunnels are the bomb
date: 2023-02-25
description: Want to expose things to the internet safely? Use Tunnels!
status: Complete
tags: 
- homelab
- k8s
---

As a self-hosted user, I understand the importance of keeping my applications and sites secure while still being able to access them from anywhere, because not everything can depend on me being on my home LAN.
That's why I started using Cloudflare Tunnels - a service that allows me to securely expose my self-hosted applications to the internet without compromising my security and it works perfectly in combination with my reverse Proxy so all I need to expose is one entry point and the proxy does the rest and provides the SSL certificates.

I also appreciate how scalable Cloudflare Tunnels is. As my self-hosted applications and traffic volumes grow, I know that Cloudflare Tunnels can handle the increased load without impacting my server's performance. And with Cloudflare use of HTTP/2 and multiplexing, I know that my application performance will remain fast and efficient.

### The Setup

Running a Cloudflare Tunnels was straightforward and easy to follow, can be done in minutes. I simply had to download and install the Cloudflare Tunnels client on my server and create a configuration file specifying the local port I wanted to expose and the hostname I wanted to use.
After running the command to establish the tunnel, I was able to start forwarding traffic to my self-hosted applications. Once you validate everything works as expected don't forget to either create a service so it can start on boot OR even better let the Cloudflare binary do it for you.

I'm not going to cover how to download the binary or setting up the account so, I'm going to refer you to the original docs [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#set-up-a-tunnel-locally-cli-setup).
You should review them if you have multiple domains or a more advanced use case but for simple self-hosted users like myself that just want to watch some videos via Jellyfin or get to my NextCloud.

Here's how my configuration ended up looking like.

```yaml
tunnel: <ID-OF-MY-TUNNEL>
credentials-file: <PATH-TO-MY-CREDENTIALS-FILE>

ingress:
  - hostname: '*.mvaldes.dev' # Domain you want to allow
    service: https://localhost # Where to send it, in my case port 443 to my localhost which is where my proxy runs
    originRequest:
      noTLSVerify: true # For my Lets Encrypt certs
  - service: http_status:404 # Where to send you if you go to a domain that doesn't exist
```

Couple things to note:

1. You need an account with Cloudflare to set up your tunnel, those are free so go get one
2. You need a domain to forward the traffic to
3. You need your proxy listening for connections on all IPs, aka having it configured as `0.0.0.0`

Don't forget the service unit so it auto starts.

```bash
[Unit]
Description=cloudflared
After=network.target

[Service]
TimeoutStartSec=0
Type=notify
ExecStart=/home/$USER/apps/cloudfared/cloudflared --no-autoupdate --config /etc/cloudflared/config.yml --metrics 0.0.0.0:3001 tunnel run
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Part of the documentation explains how you can expose metrics from the tunnel in a Prometheus format so of course I had to set that up.
Can't say no to a Grafana dashboard am I right?!?!

<img src="https://s3.mvaldes.dev/blog/cloudflare-tunnel.png" alt="tunnel dashboard" />

As you can tell from the graph and metrics my usage is very lightweight considering it's for my personal use, but this thing should be able to handle heavier workloads.

One cool thing it can do is also allow you to remote SSH into your machines, but I'm scared of even trying that, also I have no real need for it.
For accessing my machines there is always WireGuard

### In conclusion

One of the benefits of Cloudflare Tunnels that stood out to me was the protection you get from the service out of the box like DDoS attacks and can even be combined with other offerings like Firewalls.

I could be wrong on this one, but this will also help you a lot if you don't have a static IP from your ISP, meaning you can set this up anywhere.

Overall, Cloudflare Tunnels has been a great solution for me as a self-hosted user. It has allowed me to securely expose my applications to the internet without compromising my security or performance. With its ease of use, advanced security features, and scalability, I highly recommend Cloudflare Tunnels to any self-hosted user looking for a secure and reliable way to access their applications from anywhere.
This is a better solution than forwarding ports from your router to your machines, please don't do that.

Until the next one, adios 👋
