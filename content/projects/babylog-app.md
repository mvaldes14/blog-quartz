---
title: Baby Tracker Vue App
date: 2022-03-27
description: New baby, new app. An actual side project that was complete and then vanished!.
status: "Complete"
tags:
- frontend
---

My family recently expanded in numbers so with the arrival of my new baby girl ❤️, I had to remember how to wake up every couple hours, change diapers and keep track of her feeds, wet and dirty diapers up until she reaches 3 weeks or so. So when we were discharged from the hospital we were given a book with a log page so that we could track said events, but of course that book became useless when we had to wake up several times throughout the night and split the work between 2 tired and sleepy parents.

Which led my wife to use her cell phone to start writting down the events and that would solve the problem right?. Well what if I was the one who woke up, noticed the diaper and even fed her a bottle?... I would try to remember the type of event and time so she could write it down when she was awake but that model failed in less than 12 hours as I would start to mix hours and events.

So I guess it was time to find an app to use and give away my data to a 3rd party right?!?!. Hell no, as a software engineer I could create something quick and simple that would not require me to hand over any data, personal info or anything at all, which also gives me the freedom to create something that just contains the features me and the wife need.

On a fresh morning while drinking coffee the Javascript game was on, and I started coding away.

## The Stack

Since we needed something mobile friendly and my Flutter knowledge is very limited right now, I settled with spinning up a web app, make it a PWA and boom!. Native like experience.

For the stack I ended up picking these:

- VueJS cause it rocks, version 2 since it has better support for 3rd party libraries
- Buefy because I'm bad at CSS
- Firebase Firestore to keep the data synced between our phones

## The application

The UI is pretty simple, a single page application with `vue-router` rendering whatever the current route is defined as, overall 3 simple pages.

1. Add events and show the latest X number of events
2. The entire Log saved in the firestore db
3. Some overall stats.

Since this was going to be used in a mobile environment I've tried to replicate what a bottom bar with big buttons would do to switch screens but of course since it's not native and I'm pretty bad at CSS it worked, but I guess something better could be done with more time, knowledge and effort.

This application had a lifecycle of 3-4 weeks so I really didnt' want to burn my energy and time, specially since I'm already behind on sleep and feel pretty tired while my body gets used to this new workflow...so once the kiddo turns 4 weeks the app will most likely die.

### Main Page

A Simple Navigation bar with 3 buttons allowing you to add the events based on their type (feed/solid/liquid) with emojis because it makes it look good and modern am i right?!. Each click pushes an event and saves it on firestore with the current time.

Contains a small table component that only shows the latest X number of events, adjustable via attributes per component.

<img src="https://s3.mvaldes.dev/blog/app_main.png" alt="App Main Page" />

It also makes use of an optional button that displays an extra component that gives you the option to add a past event. Useful if you missed couple events.

<img src="https://s3.mvaldes.dev/blog/app_menu.png" alt="App Menu Page" />

### Log Page

A simple sortable table that shows you every single event inside the database. With an optional button that deletes the current event you click on, this one is fairly simple.

One takeaway in here would be to maybe paginate the table so that the bottom navigation bar does not get lost in the scrollbar if the table gets too big.

<img src="https://s3.mvaldes.dev/blog/app_log.png" alt="App Logs" />

### Stats Page

As mentioned at the very begining of the post, we needed to know how many wet/dirty and feeds the baby had and since counting those events in the main table was a pain, this final stats page basically served as an aggregation showing you totals for the current day, yesterday and everything else in the database.

<img src="https://s3.mvaldes.dev/blog/app_stats.png" alt="App Status" />

## Conclusion

Overall, the application did what we needed it to do. Got us through the first few weeks and actually helped us find out that our baby girl was not getting enough liquids, which turned into a doctor visit. So yay technology!.

From a tech side, I have never worked with Firebase or similar products before which are pretty cool and easy to use, I know there are OSS alternatives to Firebase like Supabase or Appwrite so I'm pretty interested in trying those out, specially since you can selfhost them!!.

The entire code for the application can be found in my [git repo](https://github.com/mvaldes14/babylog), feel free to browse it and reuse it.

I know that the firebase configuration should be kept as a secret but by the time you read this, the application will no longer have the backend enabled so nothing harmful is exposed 😗

You can visit the finished project [here](https://babylogapp.netlify.app/)

Adios 👋
