---
title: Neovim in 2023
date: 2023-09-19
description: Using Neovim entirely for over a year now
status: Complete
tags: 
- neovim
---

I've been using Neovim entirely for everything that I can for over a year now and I gotta say I won't go back to the regular old days of VScode. 
Now I'm one with Lua/Neovim and everyone else using the bloated editor is wrong (hot take 🔥).

### Here's why

1. It's way way way faster than Vscode at loading things, resource wise it's just fantastic, don't have to wait couple seconds for a project to load up and my system to start choking cause of course Electron wants 20 out of the 32GB available.
And this is not caused by something like running outdated hardware, top of the line 2019 MacbookPro can't handle a big project with 20-30 files. 

2. Can be customized to whatever you mind can think of. Need your editor to do something like idk maybe toggle or fill out a `[ ]` in your todo files where you track everything? Write a quick 15 line function in lua.
Need to be able to run something with the code you are writing? There's a probably a plugin for that and **IF NOT** you can write it.

3. Makes you faster, once you go full VIM motions you can't go back to hitting the arrows in your keyboard to find words or jump to places, you will simply become a better and faster developer by using the hot keys to get around and do things fast, like seriously fast.

4. LSPs are fantastic, now here we have to give props to Micro$oft for making LSPs a thing, deep down Vscode uses that but by letting us have clients and servers run outside of the editor we can basically have the same functionality in neovim. Which also tends to be faster.
Want to code in go? Setup the LSP. How about python? Same thing, just setup your neovim to use the lsp and the rest is history.

5. Keybind madness, this could be a pro or con cause some people might not like to have 200 keybinds to do multiple things and also memorize them so you can use them, the best thing you can do is start small and use tools like `Telescope` to see which keybindings are set up in your environment.
There's also plugins that give you visual clues as to what you set up like `whichkey`

6. You will always tweak your config, this is just a fact, once you understand how it works you will keep adding stuff to it. Welcome to the club.


### Not everything is peachy tho

1. Learning curve, the first days or weeks you are gonna try to pull your hair out cause holy molly you keep trying to use the same arrow keys or the mouse to get around. Personally the use of `hjkl` took me couple weeks to get used to.
2. Fragmented, you can extend and write plugins as you please so guess what?. There's like 25 plugins that do the same thing but with a different approach so finding a plugin tends to be hard cause theres so many that do the same thing.

3. Setup is complex, one thing that Vscode does good is the actual setup of plugins. People can find things quick while in neovim you have to know how the `rtpath` works, how plugins are loaded, when are they loaded, etc.
Which makes this not exactly beginner-friendly.


If you endured and came out triumphant you will be happy you became a neovim zealot, you will look cool when your dev friends pair with you and you will feel like a freaking hacker.
Don't trust me?; Just watch either [@teej](https://www.twitch.tv/teej_dv) or [@theprimeagen](https://www.twitch.tv/ThePrimeagen) code over at twitch and prove me wrong.


My personal setup looks like this:
{% image src="nvim.png" alt="Neovim Setup" /%}


### Conclusion
Maybe you will end up writing your own plugin for something that you wanted to do like maybe running [terraform within your buffers/windows](https://github.com/mvaldes14/terraform.nvim).
Take a leap and give it a go, have some patience and join the cult.

If you want to check out how to make your config look like mine, check out my dotfiles [here](https://git.mvaldes.dev/dotfiles)
