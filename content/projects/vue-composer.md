---
title: Docker-compose with vue
date: 2020-06-02
description: A bad attempt on building something with Vue.
status: "Complete"
tags:
- frontend
---

Due to COVID19 I finally had time to finish some of my outstanding courses, one of those was VueJs so figured i would apply it to something useful instead of doing the regular to-do apps. Which have nothing bad but they are repetitive and well, not fun to be honest.

So that being said, had a fun idea of what if I could assemble my basic docker-compose files using a web UI. I know there's plugins and things that help you template out the file but I wanted something that you could stack upon and copy to deploy to your docker swarm cluster, so vue composer was born.

## The Setup

**DISCLAIMER**: I'm Terrible at design or UX for that matter and also a bit lazy so when I saw how vuetify styles the components look super nice and how easy they were to manipulate, figured why not?

1. Install vue-cli
2. Install Vuetify
3. Spin up a project and lets get started.

## The components

The application basically uses 6 components.

1. The Home component, that just holds everything below.
2. The Navbar, self explanatory
3. The Footer, same deal
4. The Main Card component that holds 2 sub-components which are the smaller cards
5. The form component that collects the data from the user
6. The display component that shows what the user decided to save

The first 3 are sort of plain and boring so i'll skip them over, if you are curious you can checkout the code in the repo [Github](<[https://github.com/mvaldes14/vue-composer](https://github.com/mvaldes14/vue-composer)>)

### Main.vue

Component to simple display a 2 column pane that shows the form for users to enter their data in and the results once they click on "Add". The HTML portion is making use of Vuetify components and the main logic just acts as a middleman to pass data between components.

Do want to point out that by the time i created this project I was unaware of things like the Vue Data bus or Vuex so i didn't make use of them.

Here we simply register the components and create this middleman object along with a function to populate it so it can be passed.

```js
<script>
import Service from "./Service";
import Compose from "./Compose";
export default {
name: "Services",
components: {
    Service,
    Compose,
},
data: function() {
    return {
    newService: {},
    };
},
methods: {
    addService: function(data) {
    this.newService = Object.assign({}, data);
    },
},
};
</script>
```

### Service.vue

This component captures the user input, it leverages Vuetify to render nicely and we simply tie in the input boxes to objects using vue-directives.

In here we initially declare the number of services, dependencies, ports, etc. As well as create the main object that will be passed to the parent Main component. Also adding some methods to push and clear the data so the user could add new service objects.

```js
<script>
export default {
name: "Service",
data: function() {
    return {
    numberOfDependencies: 1,
    numberOfPorts: 1,
    numberOfVolumes: 1,
    numberOfEnvironment: 1,
    serviceObject: {
        serviceName: "",
        imageName: "",
        containerName: "",
        dependsOn: [],
        environment: [],
        ports: [],
        volumes: [],
    },
    };
},
methods: {
    add: function() {
    this.$emit("service-added", this.serviceObject);
    },
    clear: function() {
    var obj = this.serviceObject;
    for (const prop of Object.getOwnPropertyNames(obj)) {
        obj[prop] = "";
    }
    obj["dependsOn"] = [];
    obj["environment"] = [];
    obj["ports"] = [];
    obj["volumes"] = [];
    },
},
};
```

The tricky part here for me as a novice was on how to make the value of the property object actually clear on its own so when a user pushes the button to clear the data it would do that without removing the actual object. This was something I had to learn the hard way as the data was simply being passed by reference, meaning the value in memory/cache or whatever JavaScript uses and a new object was not being instantiated again so yeah... next time make sure that you make a copy of the object instead of passing it around like i did.

### Compose.vue

The last component simply render the object that is passed to it as the user formed it. This component is mostly a bunch of `v-for` iterating over the number of arguments in the object as the user defined them. Example of how the dependencies are rendered.

```html
<div v-if="serv.dependsOn.length > 0">
  <strong> depends_on: </strong>
  <div
    class="sublist"
    :key="dep"
    v-for="dep in serv.dependsOn"
    style="color:white"
  >
    - {{ dep }}
  </div>
</div>
```

The logic for this one is quite simple, it just pushes the object it receives from the parent Main.vue component and pushes it to the list.

```js
<script>
    export default {
    name: "Compose",
    props: {
        newService: Object,
    },
    data: function() {
        return {
        serviceList: [],
        };
    },
    watch: {
        newService() {
        this.serviceList.push(this.newService);
        },
    },
    };
</script>
```

## In Conclusion

This was a fun little project that helped me realize that I'm not that lost in terms of JavaScript, I'm no expert of course but i believe I'm slowly getting decent at it. Also VueJs has been on my radar for quite a while so this was a great opportunity for me to try it, now i need to wrap up the course, starting playing with Vuex and Vue router.... and maybe, just maybe even try some ReactJs i know that most people love it but i guess at the time i was reading documentation my overall JavaScript knowledge was so poor and JSX looked so complicated it honestly freaked me out a bit.

Another cool thing I had the chance to play with was deploying the application to a free service like Netlify as well as using the Github Registry to push the actual image so it can be pulled and used as a container in Docker or K8s.

[Vue-composer Docker Image](<[https://github.com/mvaldes14/vue-composer/packages/246204](https://github.com/mvaldes14/vue-composer/packages/246204)>)

[Github Repo for this post](<[https://github.com/mvaldes14/vue-composer](https://github.com/mvaldes14/vue-composer)>)

Finally, down the road i would like to improve on the little tool. For instance i would like to do validation so when a user enters data the tools makes sure it is in the proper format for things like ports and volumes. If Dockerhub offers an API maybe even check if the image exists, etc. Lots of things that could be done but for a novice like myself this was a good start.

You can view the finished project [here](https://vue-composer.netlify.app/)

Hope you liked it, see ya on the next one.
