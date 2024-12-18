---
title: Traefik Quick Start
date: 2020-03-13
description: Container networking is a confusing, just use Traefik instead.
status: complete
tags: 
- homelab
---

In my previous [post](https://blog.mvaldes.dev/posts/docker-home-setup) talked about how i ended up using Traefik instead of the good ol' reliable NGINX, so wanted to expand a bit more for people that may want to test this out and not want to spend hours like i did testing and reading documentation, not saying you shouldn't cause you definitely will but if you want something quick, then this guide is for you.

## Create your network

All containers that Traefik will expose need to be on the same network so if you are using something like swarm or compose, make sure you have an "external" network that all containers can reach.

**NOTE**: By default, all compose files that do not define a network will end up generating a network that will have the name of the first service in your file, this is useful so that everything in that compose file can talk to each other but in our case, it just pollutes our docker engine with more stuff to manage.

Create your overlay or bridged network

```sh
# SWARM
docker network create traefik-proxy --driver overlay

# No SWARM
docker network create traefik-proxy
```

## Setup Traefik

Traefik relies heavily configurations on either a static file that you can mount to it or by using labels, which I honestly prefer (this is referred to as dynamic configuration by them).

```yaml
version: '3.7'
services:
  traefik:
    image: traefik:v2.0
    networks:
      - traefik-proxy
    command:
      - --entrypoints.metrics.address=:8082
      - --entrypoints.http.address=:80
      - --api.dashboard=true
      - --api.insecure=true
      - --providers.docker
      - --providers.docker.swarmMode=true
      - --providers.docker.exposedByDefault=false
    ports:
      - 80:80
      - 8080:8080
      - 8082:8082
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      placement:
        constraints:
          - node.role == manager

networks:
  traefik-proxy:
    external: true
```

A quick breakdown of what these mean. A more detailed explanation can be found on the documentation - [here](https://docs.traefik.io/).

1.  Indicates that the service will use the network called "traefik-proxy".

`networks: - traefik-proxy`

2.  We define an "entrypoint" aka a port that we can hit to reach a service, and we name it "http" since its using port 80.

`- --entrypoints.http.address=:80`

3.  Traefik comes with a nice dashboard that helps you visualize what is running and the health of the services behind it, I recommend using it. So this line just enables it and allows you to reach it without using authentication

`- --api.dashboard=true --api.insecure=true`

4.  Since we are running this in a docker container we need to tell traefik to listen to events in the engine, so we enable it.

`- --providers.docker`

5.  In my case I run everything in SWARM mode so I need to enable the mode, if you are not, you can skip it.

`- --providers.docker.swarmMode=true`

6.  Finally, by default Traefik will try to match the containers against certain rules so it can expose those services, and since I didn't want to expose everything I had to turn this off. If you don't do this you will see warning messages in your container logs about not having default rules set for every service.

`- --providers.docker.exposedByDefault=false`

7.  To allow Traefik to listen in to the events for all of your containers we need to share the docker socket.

`volumes: - /var/run/docker.sock:/var/run/docker.sock`

8.  Finally since we have an external network created we need to indicate that we want to use it.

```yaml
networks:
  traefik-proxy:
    external: true
```

With that, we have our configuration set, now to configure a service

## Setup your services

In the example, we will be setting up a Grafana instance.

```yaml
version: '3.3'
services:
  grafana:
    image: grafana/grafana:latest
    environment:
      - 'GF_SECURITY_ADMIN_PASSWORD=SuperSecretPasswordMan'
    networks:
      - traefik-proxy
    volumes:
      - /opt/grafana:/var/lib/grafana
    deploy:
      placement:
        constraints:
          - node.labels.name == pi
      labels:
        - 'traefik.enable=true'
        - 'traefik.http.routers.grafana.entrypoints=http'
        - 'traefik.http.routers.grafana.rule=Host(`grafana.local.net`)'
        - 'traefik.http.services.grafana.loadbalancer.server.port=3000'
        - 'traefik.docker.network=traefik-proxy'

networks:
  traefik-proxy:
    external: true
```

Another breakdown. Same as before all of the configuration can be done via labels, which makes traefik so cool to use.

1.  First thing, we run the service in the network where traefik can reach it.

`networks: - traefik-proxy`

2.  We allow traefik to route the traffic for this service.

`- "traefik.enable=true"`

3.  Indicate which entrypoint your service will use, do note that each route you define must be unique, in the example I called the route "grafana" so replace it in your configuration as needed.

`"traefik.http.routers.grafana.entrypoints=http"`

4.  The name of the route that will be used to redirect your request to the service, in my case i have a "local.net" domain running so i ended up just giving each service a naming convention of "service_name.local.net"

`"traefik.http.routers.grafana.rule=Host(`grafana.local.net`)"`

5.  Most services expose a port so we have to tell traefik which port will be used to redirect the traffic to, Grafana does it at port 3000.

`"traefik.http.services.grafana.loadbalancer.server.port=3000"`

6.  A bit redundant but we indicate the network we are using this one as a label.

`"traefik.docker.network=traefik-proxy"`

7.  Finally, force the entire service to use an already defined external network.

```yaml
networks:
  traefik-proxy:
    external: true
```

## Validation

With traefik and our grafana service deployed and running, we can now validate with the built-in dashboard to see if our instance was picked up properly as below.

{% image src="traefik-dashboard.png" alt="Traefik dashboard" /%}

Our service in detail, the route and the service.

<img src="https://s3.mvaldes.dev/blog/grafana-traefik.png" alt="Traefik in Grafana" />

In our browser, if we navigate to `http://grafana.local.net` we should in theory now be presented with the default grafana setup. In case you don't see it you might have DNS problems, the easy workaround is to add the name of the site to your `http://localhost` so it resolves the traffic.

```sh
# /etc/hosts
127.0.0.1 localhost grafana.local.net
```

If you run your own DNS server like me you can simply add a CNAME record that points to the server that hosts the service, done properly you should see.

<img src="https://s3.mvaldes.dev/blog/grafana-dashboard.png" alt="Traefik dashboard in Grafana" />

## Conclusion

Hope the mini-guide helped you out on how to set up your services, once you have one running it should be easy to replicate by simply copying the configuration and replacing couple values. The traefik documentation also provides a couple of examples in case you wanted to have your routes setup like `domain-name.com/grafana`. Finally, you could also have some middleware for your services in case you want to put some authentication before a user can get to your service which is always a good idea if you end up running things for a bigger group or PROD.

Then again I'm the only one that uses these at home so why bother right?

As always if you have questions you can reach out to me on social media.
