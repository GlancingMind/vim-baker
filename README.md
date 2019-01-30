# Baker - Better :make!

Baker is a plugin for the fantastic [vim editor](https://github.com/vim/vim/).
The Plugin provides a simple build system based on makefiles. It introduces
a new command `:Baker` which set the `makeprg` option and calls `:make`.

## Motivation

Imagine you have a makefile with multiple targets e.g. release, test and debug.
I wanted the this targets to be listed as completions for the `:make`
command. So I could see all available targets, select my prefered ones by hitting
tab a few times and finally invoke `:make` on them. This relieves me from
remembering and typing these targets all over again, when I have to use `:make`.

## Installation

Use your favorite plugin manager.

Using [vim-plug](https://github.com/junegunn/vim-plug)

    Plug 'UnintendedSideEffect/vim-baker'

## Getting Help

For those who seek the enlightenment, see `:h baker`. May you find what you're
looking for.

## Contribute

Some rules from [Google Vimscript Guide](https://google.github.io/styleguide/vimscriptfull.xml) were used as reference.

If you find a bug or have ideas for improvement, feel free to open an issue.
