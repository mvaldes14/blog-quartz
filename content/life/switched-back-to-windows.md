---
title: Windows is decent again?
date: 2020-07-19
description: Windows can do what now?. Honestly shocked on what you can do in a windows workstation now.
status: complete
tags: 
- random
---

<img src="https://s3.mvaldes.dev/blog/winfetch.png" alt="Windows fetch" />

Been using windows again for almost 2 months now and I gotta hand it to them, it has improved **quite a lot**. Last time I had it installed on my system was around 2017 when at some point I wanted and needed to play more with the LINUX operating system for work purposes so I could understand it more and honestly I was a bit tired of the constant updates that took forever... additionally had always been tempted to make the switch so I backed up everything and kissed goodbye to my old OS.

I did miss the one windows perk which was playing AAA games, at the time I was super into PUBG and it was and I believe still is unplayable in Linux but soon after something called **Proton**...started to pop up more and more, turns out at the beginning of 2020 I could play almost \*everything\* in my Steam library using my Linux OS except couple new and fancy games that I was dying to play and couldn’t be emulated properly, so I entirely blame the switch on Doom Eternal and COD Warzone.

So I downloaded a copy of windows and created the image on a boot drive and so it began… wiping the drives and installing Windows once again, it took almost 30 minutes including the number of restarts it has to do to make sure everything is done properly and setting up the accounts and whatever else it does, finally it was complete and I was presented with a fresh copy of Windows, it still had a bunch of bloatware I did not need and I still feel it shouldn’t even be installed on the system to begin with but that’s for another day. Now I do have to add, I kept using the Windows at work and with new additions like WSL the switch was even more tempting cause I could use it without being blocked by company policies in the work equipment.

One of the great perks of Linux distributions is the package managers (yum, apt, pacman, etc) which is something that I always wished windows would have so I could [automate everything like I did before](https://blog.mvaldes.dev/posts/ansible-boostrap). So googling around I found that windows is already working on it’s own [package manager](https://docs.microsoft.com/en-us/windows/package-manager/) which was awesome but for the meantime I also found chocolatey so I quickly looked up my most common apps and installed them incredibly easy, no need to download a bunch of installers or to get them from dubious sites, again in a matter of minutes my system was ready.

An extra item I did not expect was that the Windows Terminal was **pretty decent**, I mean it's not going to compete against Konsole in KDE but for being their first try it's damn good, you can blur the background, change the colorscheme, use custom fonts and it has tabs that take you directly into a WSL distro, once again, very impressed. I have uploaded my personal configuration file to my [dotfiles](https://github.com/mvaldes14/dotfiles/) in case you are curious.

The cherry on top was installing WSL, by the time I switched WSL2 had just come out so I enabled it and installed it, got docker running on top of it and got 2 distros to play with (Ubuntu 20.04 and Kali), hell I even ran my ansible playbooks against one of the distros just to install some software as well and everything was working as expected, I was honestly shocked at how good the performance was, I mean I’m not doing hardcore stuff but to have my containers running over and all of my software dev kit installed and running from WSL2 into windows was just magnificent. This post was written in Vscode running in Windows but connected to a WSL2 backend, how crazy is that!?

At the end I had it **all**:

1. I could play my AAA games like Doom and CODWZ
2. I could quickly jump into my WSL2 Distros to play and try new technology.
3. I can install a lot of things from the CLI using chocolatey and I'll be waiting for the Windows official version.
4. I have a pretty good looking terminal.

I’m honestly very pleased with it now and with the amount of things coming down the pipeline for windows I am for once excited about the future of it, like running GUI apps from within WSL, the package manager and if they clean up their privacy stuff I believe it could start pulling some of the market of users like me that want to develop things but also enjoy playing some good games.
