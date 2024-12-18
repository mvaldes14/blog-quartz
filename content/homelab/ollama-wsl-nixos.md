---
title: Ollama in WSL + NixOS
date: 2024-10-08
description: Quick way to get your own LLM locally
status: Complete
tags: 
- wsl
- nix
---

While setting up my new computer and WSL + NixOS (btw), I needed to set up my own quick LLM to ask dumb things and integrate it within my NeoVim experience using the [Ollama Plugin](https://github.com/nomnivore/ollama.nvim).
So here's the quick guide on how to get that done since it can be tricky to decide things like:

- Should Ollama be installed within my WSL host?
- Specially in NixOS do I need to set up some weird service?
- Do I maybe install it directly on Windows?
- Why is my life so complicated as a Nix user?


So for whoever is reading this and wants to get the setup done quick here's what I did after struggling with all the above questions. The last one still hurts.

1. Do not install the NixOS app, it seems like it just gets you the CLI wrapper, but there's no service or anything running.
2. You might think well I'm going to install the service as well, don't, it takes ages to compile and run and it will not use your GPU. The cli won't even recognize the service so WTH?.
3. Install Ollama on your windows host directly by following [this](https://ollama.com/download) and proceed to install the models via Powershell or your personal terminal emulator.
    - If you want to make this work in your own emulator make sure the `ollama.exe` is added to your path
    - In NixOS you can add all of the windows PATH to your WSL by enabling `  wsl.interop.includePath = true;`
4. With Ollama and some models you will still not be able to hit the API, so you need to tell the service to run on 0.0.0.0. **NOTE:** By default it's just listening on 127.0.0.1 = you cannot hit it from within WSL.
5. Set up an Environment Variable in Windows `OLLAMA_HOST=0.0.0.0`
6. Restart the Ollama service (Kill the app in the tray icon and start it over)
7. Validate you can hit the API `nc -zv <ip-of-your-window-host> 11434`. You can get the IP by running `ifconfig` in your Windows host.
8. Profit!

There are currently couple issues in Ollama's Github tracker related to the fact that not all interfaces can hit the services so hopefully down the road it becomes a setting we can do via UI or a service definition. Meanwhile an environment variable will suffice.

If you did everything right you should now be able to connect to the API from your editor of choice and start using the benefits.
I know there are some Obisidian Plugins as well that can leverage Ollama for completion or better notes, so maybe that's something I will explore next!.

Hope this quickie one helps you!

Adios 👋

