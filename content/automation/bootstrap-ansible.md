---
title: Bootstrap your system with ansible
date: 2019-08-20
description: Tired of setting up your system whenever you change distros? So am I.
status: Complete
tags: 
- automation
- ansible
---

I've been distro hoping for a month or so now trying to find the perfect balance between productivity and ease of use as well as aesthetics, so I could feel comfortable using my computer for more than just messing around (Ended up staying with Manjaro KDE in case you were curious).

Anyways, doing so made me install over and over again some packages and apps every single time. I know I could've backed up the entire `/home` partition but there were still some dependencies and libraries needed so instead of doing this repetitive process, figured I'd use automation tools, like ansible.

1. First, i came up with a list of everything i had installed already. Depending on your distro you can check your `/var/log/pacman.log` or do an extract using `pacman -Ql.`
2. Next was to create a repo that would hold my special application configuration files as well as the playbooks so I can simply copy those into my new system and just run them.
3. Finally, create an ansible role structure for all the different things I've wanted to install, I'm a fan of keeping things tagged and organized as well as having some specific things installed in specific devices, like steam and my games are useless in my personal laptop so having things separated by roles helps a ton.

With the list and structure ready, ended up with something like this.

```yaml
--- # Main playbook
- hosts: local
  gather_facts: no
  connection: local
  roles:
    - aur
    - base
    - python
    - games
    - pi
    - snaps
```

So all my tasks were separated based on the source or module being used by them. Do note that in my case since I'm an Arch user, had to install a module for ansible in order for me to get things from the AUR. Ended up using [`https://github.com/kewlfft/ansible-aur`](https://github.com/kewlfft/ansible-aur). The rest of the modules are built-in assuming you have Ansible v2.8.

All that was left was to define the tasks inside each role and start running things. If you want to see the full thing, refer to my [dotfiles](https://github.com/mvaldes14/dotfiles). But here's a brief example of what I consider my base packages.

```yaml
--- # tasks file for base items
- name: Install applications from pacaur
  become: yes
  become_method: sudo
  pacman:
    name: '{{ item }}'
    state: present
  loop:
    - rofi
    - imagemagick
    - docker
    - jq
    - neovim
    - nodejs
    - npm
    - playerctl
    - vagrant
    - virtualbox
    - lxappearance
    - chromium
    - neofetch
    - postman-bin
    - rsync
    - rclone
    - spotify
    - visual-studio-code-bin
    - mpv
    - xclip
    - redshift
    - fzf
    - httpie
    - zeal
    - lastpass-cli
    - nmap
    - prettyping
    - bat
    - ncdu
    - python-pip
    - pavucontrol
    - pulseaudio-alsa
    - adobe-source-code-pro-fonts
    - noto-fonts-emoji
    - yay
    - dropbox
    - konsole
    - transmission-gtk
    - clementine
    - krusader
    - wps-office
    - zsh
    - go
    - terraform
    - firefox
    - filezilla

    - arch-base
```

One thing I would've loved would be a way to run just specific roles but that seems to be not doable right now so we use the next best thing, tags in the playbook tasks.

So for example if i just want to run the playbook to install things from AUR.

```yaml
- name: Install from AUR
  aur:
    use: yay
    skip_installed: yes
    aur_only: yes
    name:
      - ttf-font-awesome-4
      - snapd
      - ttf-material-design-icons
      - mailspring
      - wireshark-gtk
      - android-studio
      - bind
      - slack-desktop
      - discord
      - tor-browser

      - arch-aur
```

It can be run with something like.. `ansible-playbook main.yml -t arch-aur -K`

Breaking it down:

- `main.yml`: The name of the principal YML file that contains all roles.
- `-t` arch-aur: We specify that we only want to run the portion where the tag is arch-aur.
- `-K`: to provide our root password so that the administrative actions can take place.

Simple as that i can have a fully bootstrapped system ready to go in minutes, this project was extremely helpful for the distro hoping portion as mentioned in the beginning but since i moved away from windows on my laptop and honestly didn't want to spend a lot of time doing the whole thing, the playbook schema worked out perfectly. Also having the tags for different systems i could specify what to run where.

At this stage, the execution of those filters is done manually by using tags but you can improve on the playbook by comparing the name of the system and just executing certain roles based on conditions, in my case since i don't plan to do the installation for a while now i can live with manual portion. Next stop would be to find a way for me to keep the list updated every time i install something from either pacman, aur, snap, etc. Guess that will be the next project for the future.

Hope you liked it, see you next time.
