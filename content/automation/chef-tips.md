---
title: Chef Tips and Tricks
date: 2022-12-10
description: Chef tips and tricks I wished I knew when I started
status: Complete
tags: 
- chef
- automation
---

Lately I've been pretty deep into the Chef weeds and the more I end up working on it, the more I keep finding these little tips and tricks on how to get something done, some of these come from Seniors that passed them on to me and some of them I either end up finding online or figuring them out so would like to share them in case someone finds them useful.

# Need to run a command and use the output for something?

There is the `execute` or `ruby_block` resources but what if you need the output of something to determine if a resource should run or not?. Maybe its a guard for another resource in your recipe, simple, use the `mixlib/shellout` library. Should be installed since it's part of Chef SDK.

```ruby
require 'mixlib/shellout'
find = Mixlib::ShellOut.new("find . -name '*.rb'")
find.run_command

 # Grab the output either good or bad
puts find.stdout
puts find.stderr
```

# Copy a local cookbook to a node with chef installed

If you ever need to see how your cookbook will be applied to a machine but you are not ready yet to push it out to your chef server?. I gotchu, you can simply zip the entire cookbook and copy it over to a node and then apply a new runlist!.

- Copy the tarball and put it somewhere
- Modify the client.rb to point to a directory holding the cookbooks (it must contain the metadata.rb)
- Edit the client.rb so it fetches from a local path, the cache location is a good spot since it already has your cookbooks.

```bash
  cookbook_path    /var/cinc/cache/cookbooks
```

- Run cinc client in solo mode and specify the runlist, it is important you run this with `-z` so its done in `solo` mode. Meaning it won't reach out to the chef server to fetch data.

```bash
cinc-client -z -r "yourcookbook::recipe"
```

Your cookbook should now be applied to the instance, hack away!

# Test a resource before putting it in a cookbook

In a node with cinc installed you can enter into the shell and go inside `recipe_mode` to test out resources. If you are happy with them you can later run `run_chef` to actually execute them against a node. This is great to test and design cookbooks.

```bash
cinc-shell -s

cinc (17.9.26)> recipe_mode
cinc:recipe > git '/tmp/dotfiles' do
cinc:recipe >   repository 'https://github.com/mvaldes14/dotfiles.git'
cinc:recipe (17.9.26)> end
 => <git[/tmp/dotfiles] @name: "/tmp/dotfiles" @before: nil @params: {} @provider: nil @allowed_actions: [:nothing, :sync, :checkout, :export, :diff, :log] @action: [:sync] @updated: false @updated_by_last_action: false @source_line: "(irb#1):1:in `<main>'" @guard_interpreter: nil @default_guard_interpreter: :default @elapsed_time: 0 @declared_type: :git @cookbook_name: nil @recipe_name: nil @repository: "https://github.com/mvaldes14/dotfiles.git">
cinc:recipe (17.9.26)> run_chef
[2022-10-12T20:56:21-05:00] INFO: Processing git[/tmp/dotfiles] action sync ((irb#1) line 1)
[2022-10-12T20:56:22-05:00] INFO: git[/tmp/dotfiles] cloning repo https://github.com/mvaldes14/dotfiles.git to /tmp/dotfiles
[2022-10-12T20:56:23-05:00] INFO: git[/tmp/dotfiles] checked out reference: 5c362e70aaa0c51055df0c7015582d89ab3e1017
 => true

```

# See attributes on instance

This is useful to debug if an attribute does not behave as you expected or if you have a lot of overrides and don't know which one is the final one being kept. Also helpful in case `ohai` replaces something you were expecting.

**If its in a kitchen converge do**

```sh
cd /tmp/kitchen
cinc-shell -c client.rb -j dna.json
node['attribute']
```

**If it is an already bootstraped instance then**

```sh
cinc-shell -z
node['attribute']
```

# Run systemd inside of test kitchen with dokken

This is pretty useful if you are not using vagrant to test out your kitchen instances and prefer something quicker like Docker, which works great except when you need to interact with systemd to actually start/enable a service you just installed.
For those scenarios you can simply `pass or mount` part of your cgroups so systemd runs inside the container.

NOTE: This only applies if you are using NIX as the base machine to develop your cookbooks, for other OS I honestly have no clue... maybe just use vagrant.

Your kitchen.yml should looks something like this.

```yaml
driver:
  name: dokken

transport:
  name: dokken

provisioner:
  name: dokken

verifier:
  name: inspec

platforms:
  - name: centos-7
    driver:
      image: centos:7
      privileged: true
      pid_one_command: /usr/lib/systemd/systemd
      volume:
        - /sys/fs/cgroup:/sys/fs/cgroup:ro
```

Those are some of my most precious tips so hopefully they serve you well.

If you got more tips on how to do magic things in Chef please do let me know so I can learn and include them into my blogs and wikis!.

Until the next one, adios 👋
