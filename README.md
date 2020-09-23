# Baker - Better :make!

Baker is a plugin for the fantastic [vim editor](https://github.com/vim/vim/).
The Plugin intends to improve the invocation of a makefile's targets by
introducing a new command `:Baker` which autocompletes these targets, set the
`makeprg` option to the selected target and calls :make.

## Motivation

Imagine you have a makefile with multiple targets e.g. release, test and debug.
I wanted this targets to be listed as completions for the `:make` command.
So I could see all available targets, select my preferred one's by hitting
tab a few times and finally invoke `:make`. This relieves me from
remembering and typing these targets all over again, when I have to use `:make`.

## Installation

Use your favorite plugin manager.

Using [vim-plug](https://github.com/junegunn/vim-plug)

    Plug 'GlancingMind/vim-baker'

## Getting Help

For those who seek the enlightenment, see `:h baker`. May you find what you're
looking for.

## Contribute

Some rules from [Google Vimscript Guide](https://google.github.io/styleguide/vimscriptfull.xml) were used as reference.

If you find a bug or have ideas for improvement, feel free to open an issue.
