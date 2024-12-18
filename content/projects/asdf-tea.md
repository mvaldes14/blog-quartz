---
title: Introducing asdf-tea
date: 2023-07-24
description: An asdf plugin to install gitea tea cli utility
status: "Complete"
tags: 
- cli
---

I've been using asdf a lot lately to manage all of my languages versions and random packages that simply do not have an easy way to install
or are just convenient to have. So with that in mind I've tried to adapt the CLI workflow for my git projects, and I'm already pretty used to using `gh` for GitHub,
but since most of my projects live on my personal [Gitea instance](https://git.mvaldes.dev) I was looking for a similar experience where one could simply create PRs, Issues, etc.
Thankfully the Gitea project offers a similar CLI that can almost go toe to toe vs Github but there was a minor problems. You needed to download the compiled binary and then put it in your path... give it the proper permissions and that was just too much,
So I spent an hour or so reading how asdf plugins work and decided to make my own.

If you are curious here's the list of what i currently install with asdf:

- golang
- helm
- jq
- kubectl
- lua
- nodejs
- ruby
- rust
- stern
- terraform
- terragrunt
- awscli
- sops
- lazygit
- tflint

Like I said mostly languages and utilities.

So now.. Introducing asdf-tea...which is pretty boring in essence cause ultimately it just downloads the binary and lets asdf handle how it's called and installed...but I guess it's now a mini project I will try to maintain, so other people like myself can just use and that's the beauty of open source right?

To get some tea simply do `asdf plugin add tea https://github.com/mvaldes14/asdf-tea` followed by `asdf install tea latest` & `asdf global tea latest`.

Then you can `tea login` and go to town.

Hopefully someone out there can benefit from this little project.

Want to take a peak at the code? Go [here](https://github.com/mvaldes14/asdf-tea)
