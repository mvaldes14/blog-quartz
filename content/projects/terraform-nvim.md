---
title: Navigating Terraform manifests in Neovim
date: 2023-07-28
description: My first neovim plugin that actually works.
status: "Complete"
tags:
- neovim
- IaC
---

Part of my work requires me to work with terraform...a lot of terraform since everything has to be done via IaC, or it simply doesn't go through AWS, so since my editor of choice is Neovim and anyone can basically create any extension to do whatever...I figured why not have a dedicated terraform plugin to do some planing and exploring?!. 
So with that mindset `terraform.nvim` was born. 

It all started with the idea of...

**What if I could preview my plans within the editor like in a floating window?**, something like that is pretty easy to do in native Neovim with just opening a new terminal buffer on a side and literally running whatever you wanted. 
But that isn't fancy, and you got to switch between those buffers to go back and edit code, then switch again and re-run your plan. You can see how this can get annoying really fast. 

So what if a new floating term would open up and run that plan for you? And that all could be invoked in a key bind? - `:TerraformPlan` became a thing you could do. 

Once that was working, the next step was finding a way to navigate an existing code base that contained hundreds of resources confined within the working directory...one idea was to just `ripgrep` and find things, but there's also a plugin called `Telescope`, and it's kind of my favorite thing about Neovim and you can make "extensions" for it. So you see where this is going. 
What if you could navigate your entire codebase grabbing it directly from the terraform state and present it in a little window that could let you fuzzy find things?; Also what if that window could show you how that current resource in your cursor looked like in the actual provider?. And same as before you could basically bind that to a key?. 

That's how `:TerraformExplore` was born. And it's probably the thing I like the most about the plugin, having the ability to quickly find and edit resources is just amazing. Specially if your manifests contain couple resources per file and your current working directory has more than 30 files... It becomes a nightmare to fuzzy find and locate things effectively. 

Some screenshots on how it all works

Terraform Plan telling me what will change. 

<img src="https://s3.mvaldes.dev/blog/terraform-plan.png" alt="Terraform Plan"/>

Terraform Explore without a search parameter, notice how the state shows up in the previewer

<img src="https://s3.mvaldes.dev/blog/terraform-explore.png" alt="Terraform Plan" />

Once you find the resource you can simply "Enter" on it and the plugin will take you directly to the line that contains that resource, so you can edit it.

<img src="https://s3.mvaldes.dev/blog/terraform-explore-pick.png" alt="Terraform Plan" />

There are still couple things I would like to add to the plugin like: 
- Starting your terraform project if not initialized
- Terraform Apply with a confirmation pop up window
- Tune up the performance as terraform plan can take some time depending on the number of resources in state, maybe cache it somewhere?
- Terraform Module support, picking a resource that is a module is tricky

As with any other open source project and specially Neovim plugins, the community feedback is always welcome and someone else might find more use cases for something like this. 
If not I know for sure it will help me at work. 

Not to mention that this is my very first plugin, and it was a blast to make, learned a lot on how Neovim internal kind of work and how to leverage buffers and other plugins to build upon. 

10/10 would recommend anyone using Neovim to build a plugin just to learn.

**Fun fact, doing this plugin made me feel comfortable to tackle a linter for `nvim-lint` as a replacement for null-ls and got my [PR](https://github.com/mfussenegger/nvim-lint/pull/330) approved and merged, quite happy about it.**

If you find this useful don't forget to give it a star over at [GitHub](https://github.com/mvaldes14/terraform.nvim)
