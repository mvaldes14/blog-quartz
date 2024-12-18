---
title: Terraform Automation with Atlantis
date: 2023-10-04
description: Want to look cool and deploy your infra like an enterprise would? Get some Atlantis into your homelab.
status: Complete
tags: 
- automation
- iac
---

In big enterprises with decent IaC experience and infrastructure footprint you as a good engineer will use some sort of workflow to allow teams to deploy their infrastructure as code, so that things are controlled, centralized and manageable for whoever is paying the cloud bill.

So with that in mind there are a lot of companies and products that can help you keep that terraform under control (speaking of which, with the new License changes those companies are in trouble, enter 'OpenTofu' that's a story for another day), one of the tools that I'm familiar with and enjoy using is [Atlantis](https://www.runatlantis.io/) which takes care of planning and applying as long as conditions are met.

You will ask yourself, now that sounds pretty cool, but I'm just a guy with a bunch of computers in the basement why would I care about IaC and automated workflows with fancy tools?

<img src="https://media.tenor.com/j81mTyJs0lIAAAAC/steve-carrell-michaelscott.gif" alt="you are not wrong" />

To which I will argue, yeah it's kind of redundant when you are the sole user of your infrastructure but one thing to remember is that us techies like to play with new toys. So in this post we are going to setup Atlantis to automate my Homelab shenanigans.

## How does Atlantis Work?

Good question, well it basically connects to your GitHub/Azure/Gitlab instance or account and listens for events on certain repositories. Once it detects a change it will kick-start an execution of terraform on whatever path the project resides.

With the plan complete, it will update your PR with a comment giving you the details of what will be created. If everything looks good you can then "approve" the changes and Atlantis will apply them as planned.

## I'm sold what do I need?

I won't bore you with the details as the documentation will do it way better than I can, but long story short you need to acquire couple tokens so your Atlantis instance can connect safely to GitHub to listen for events.
Documentation can be found [here](https://www.runatlantis.io/docs/installation-guide.html)

If you like to run things in containers like I do., his is how my yaml looks like, minus the secrets of course! Keep those hidden!. Feel free to use it as a base.

```yaml
atlantis:
    image: ghcr.io/runatlantis/atlantis
    environment:
    - ATLANTIS_GH_USER=<your-gh-user>
    - ATLANTIS_GH_TOKEN=<your-token-from-gh>
    - ATLANTIS_REPO_ALLOWLIST=github.com/mvaldes14/terraform || <your-repo>
    - ATLANTIS_ATLANTIS_URL=https://atlantis.mvaldes.dev || <your-available-instance-dns>
    - ATLANTIS_GH_WEBHOOK_SECRET=<your-webhook-secret>
    - ATLANTIS_EMOJI_REACTION=thumbsup
    - ATLANTIS_API_SECRET=<random-secret-for-atlantis-to-validate>
    - ATLANTIS_TFE_TOKEN=<your-hcp-cloud-token>
    - ATLANTIS_TFE_LOCAL_EXECUTION_MODE=true # Enable or disable as needed

```

> Having a good repo structure is crucial to having a good workflow experience, otherwise you are not going to have a good time.

With everything running now you need to configure your repo with a proper `atlantis.yml`, so it knows where to go and what to read. In my case I have separate state and manifests depending on which "app" they belong to. 
You can also split this by environments, providers or vendors. Again the key is to have a good structure, so you can manage it.

Here's my [repository](https://github.com/mvaldes14/terraform) if you want to see the layout.

Example of how my atlantis.yml looks like:
```yaml
version: 3
automerge: true
delete_source_branch_on_merge: true
projects:
  - name: grafana # Project Grafana
    workspace: grafana # Each Project has it's own workspace
    dir: apps/grafana # What folder to monitor
    autoplan:
      when_modified:
      - "*.tf" # Which files types will trigger a plan,
        # Useful to prevent executions on README or makefiles.
  - name: aws  
    workspace: aws
    dir: apps/aws
    autoplan:
      when_modified:
      - "*.tf"

```

**NOTE:** If you like to store your state in HashiCorp Cloud like I do, your **apply command needs to be different cause of a bug with remote execution**. You can set your execution to local, but you will need to pass in the secrets/variables to atlantis in order for it to work.

<img src="https://s3.mvaldes.dev/blog/atlantis-1.png" alt="atlantis PR" />

You can expand on the plan details to see what resources will be created. And if everything pleases you, simply put a comment in the PR saying `atlantis apply -- -auto-approve`, and it will create the resources and also merge the PR, cause that's what the configuration says remember?

<img src="https://s3.mvaldes.dev/blog/atlantis-2.png" alt="atlantis plan details" />

**It is very important you auto-approve it, since HCP forcefully wants you to use their UI to approve any changes before they can apply it so it kind of breaks the nice flow you can get with Atlantis, see [issue](https://github.com/runatlantis/atlantis/issues/2794) for more details**

If everything was done right, your PR will be merged and your infra should be ready for you.

## Conclusion 

It is very important to design your IaC pipeline "correctly" and how you will manage it. So put these in a balance and pick your poison.

- Do I want/need to store the state in s3?
- If not, do I even want to worry about state?; It's the most complex part about terraform IMO.
- How will I manage the secrets for the execution?; Those AWS Keys and Tokens have to be safe and providing them on each execution is not ideal.
- How will I separate my resources, so I don't end up with a state file having 1203019809 resources?
- Who will review and approve my changes before they go live?; Do we just allow anyone to create infra?

For your Homelab none of this would potentially apply, but now that you have an idea how pipelines for IaC with Terraform work, you might figure out how to apply these at your work and expand on them.
We didn't go over variables and secrets, but maybe that's another post down the road.

Hope you liked it!.

Adios 👋
