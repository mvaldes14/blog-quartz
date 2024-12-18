---
title: I Love/Hate Nix
date: 2024-05-06
description: I use nix (btw)
status: Complete
tags: 
- nix 
- wsl
---

I've always tried to automate my working environments in either a personal or professional setup. So years ago, I created a repository for my dotfiles which has been curated over the years with my custom applications, aliases or anything that I found useful or repetitive. All of that worked out just fine, at some point I even went all in into actual automation by using Ansible to set up my multiple machines, which also has its own repository if you are curious.

Life was good, and it seems like people were using either Ansible or asdf (hell I even wrote a plugin for that [ remember](http://localhost:3000/projects/asdf-tea)) to sort of automate their development setups, then Nix appeared with that damn smile.

<img src="https://s3.mvaldes.dev/blog/nix-meme.png" alt="that smile" />

I've heard of Nix before but never really did much with it cause it honestly looks super complicated to get started with, but as software engineers we like to suffer in silence. It all imploded when I saw one of my favorite streamers [ALT-F4-LLC](https://github.com/ALT-F4-LLC) use Nix for basically everything, and he was kind enough to explain all of us, and he still does explain people whenever they ask on stream how it works and how to get started so with that motivation it was time to jump into the abyss of Nix.

## What the hell is nix anyway?
Well it's 3 things according to a lot of people, it's called the nix trinity:

<img src="https://s3.mvaldes.dev/blog/nix-trinity.png" alt="nix-trinity" />

So with that in mind, I'm currently using 2 out of 3 of those components.

1. The Package Manager
2. The Nix Language
3. The operating system

The package manager helps me basically install anything that I would ever need on my system, it also lets me declare what my computer will need in a file so if for some reason this one blows up I can always just recover in seconds by using the configuration file, think of it like GitOps but for your personal system (this can also be applied or used on production machines that need to have certain pieces of software installed/enabled).

Then the Nix Language which is the part that I was scared of the most is a way to declare functionality and let you configure your system in various ways. The 3rd part which is NixOS is where it all sort of comes together as you can basically create a new "generation" of your machine by modifying and applying the latest version of your configuration file. The language itself isn't exactly super complex, but it's syntax for someone that me that isn't used to something simpler than python/Golang looks a bit odd. But at the end of the day it has its little gotchas and once you go over that portion it's a bumpy ride but a pleasant one (remember we like suffering).

Which takes me to one of the big first problems with Nix as a whole, and it's something a lot of other people express as well.

> The documentation is all over the place and there's a million ways to do the same thing

But fear not, ChatGPT has been pretty good at telling me how to overcome certain obstacles while using Nix.

## Show me what I can do with it already
Alright if you are sold on the idea, you can install Nix in your system by following the official documentation. You might want to start with the package manager which comes with the language portion.

Once it's installed you can then start defining "shells" or building "packages". In all the examples we will be using nix flakes which are "experimental" but pretty reliable and help you reproduce things pretty nicely.
So make sure you enable that following the [ documentation ](https://nixos.wiki/wiki/Flakes).

__Think of Flakes as the equivalent of using your package manager (npm, poetry, gem) that will grab dependencies and generate a lock file, so it knows what to use__

Let's begin with an example of a shell that will have something like psql that is part of the postgresql package. Create a `flake.nix` file and include this.

```nix
{
  description = "Loads PSQL";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    outputs = { nixpkgs, self}:
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
      in {
        devShells.${system}.default = pkgs.mkShell {
          buildInputs = [
            pkgs.postgresql
          ];
        };
      };
}
```

> The file may look complex but in reality it's just inputs and outputs declared.

With the file created now you can do `nix develop`. Nix will find your flake file and use it to build a shell environment.
You can now do `psql` and use it to connect to a database. 

__This is the power of Nix__, having the option to run certain packages on certain projects where a `flake.nix` file resides. Now you can make that array bigger and start including whatever your project might need and do remember that the __nixpkgs repository has more packages/apps than the AUR which is considered to be massive.__

### Automate your shells
If you are now somewhat sold, what if I told ya you won't need to run nix develop and as soon as you change directory into something with a flake everything will be prepared and enabled for you to use?.
That where `direnv` comes in, it's another project/tool that basically allows you to automagically load your environments as soon as it sees a `flake.nix` and a `.envrc` file. 

If you want to set it up please follow the [instructions](https://github.com/nix-community/nix-direnv)

Here's an example on how it works.

```bash
# before direnv
➜  psql
The program 'psql' is not in your PATH. It is provided by several packages.
You can make it available in an ephemeral shell by typing one of the following:
  nix-shell -p postgresql

# after direnv
direnv: loading ~/git/example/.envrc
direnv: using flake
direnv: nix-direnv: using cached dev shell
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIR
➜ psql --version
psql (PostgreSQL) 15.6

```

I find that pretty cool honestly. Loading everything as soon as you enter a folder/project?

<img src="https://c.tenor.com/BwoIhzZB-kIAAAAC/tenor.gif" alt="mind blown" />
## How can I use it to build things?
If development environments were not enough to impact you, then let's see how we can sort of replace Makefile with nix too.

Let's pretend you have a Go app, and you want to build or run it without using go build or go run which can receive more parameters to build it for certain architecture or find your package somewhere where your main package resides.
Maybe also use Nix to build the docker application.

The function/packages `mkShell` used in the previous example, is one of many things you can leverage. So let's use some other functions `buildGoModule`.

```nix
{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      name = "your-project-name";
      vendorHash = "yourProjectHash";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.packages.${system}.default ];
        nativeBuildInputs = [ pkgs.air pkgs.templ pkgs.sqlite ];
      };
      packages.${system}.default = pkgs.buildGoModule {
        inherit name vendorHash;
        src = ./.;
      };
    };
}

```
Now doing something like `nix run` or `nix build` will allow you to have either the binary built or can even be expanded to do things like building a docker image you can then export/load/push onto a registry.

The trick in the flake above is the use of module `buildGoModule` which basically knows how to build go packages. Similar to this function, you will find them for different languages. Or you can always go raw and use `mkDerivation` which lets you control what to run and what to inject into the sandbox nix creates while building your project.

__Note: This was a very quick intro guide on some of the power of nix + flakes so if you would like to see more, or ask questions feel free to jump on stream and ask away!.__

# Conclusion
The more I play with Nix the more I Hate/Love it because:

- Everything can be declared and reproduced
- The language is sort of a pain to work with sometimes (Functional programming type of deal) and also the syntax is weird in my opinion.
- Documentation is scarce, so sometimes ChatGPT is your best bet
- Nix can do pretty much anything in a computer
- NixOS can do even more cause it lets you spin up services, packages or whatever you need
- You can install and find pretty much anything in the repository
- Allows me to say, I use Nix btw.

If you would like to learn more there are excellent tutorials and blog posts out there, some of the stuff that helped me:

- [Building a rust service with nix](https://fasterthanli.me/series/building-a-rust-service-with-nix)
- [Go Programs Nix](https://xeiaso.net/blog/nix-flakes-go-programs/)
- [NixOS and Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Nix Wiki](https://nixos.wiki/wiki/Main_Page)

Hope you like it.
Join the nix cult!

Adios 👋

