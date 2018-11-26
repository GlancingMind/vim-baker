# Baker - Better :make!

Baker is a plugin for the fantastic [vim editor](https://github.com/vim/vim/).
The Plugin provides a simple build system based on makefiles. It introduces
a new command `:Baker` which set the `makeprg` option and calls `:make`.

## Motivation

Imagen you have a makefile with multiple targets e.g. release, test and debug.
I wanted these targets to be listed as completions when I use the `:make`
command. So I simple could make a mapping to `:make` and hit tab a few times
to select my prefered target. This relieves me from remembering and typing
these targets all over again, when I have to use `:make`.

## Installation

Use your favorite plugin manager.

Using [vim-plug](https://github.com/junegunn/vim-plug)

    Plug 'UnintendedSideEffect/vim-baker'

## Getting Help

For those who seek the enlightenment, see `:h baker`. May you find what you're
looking for.

## Contribute

I used some rules from [Google Vimscript Guide](https://google.github.io/styleguide/vimscriptfull.xml) as reference.

If you find a bug or have ideas for improvment, feel free to open an issue.
