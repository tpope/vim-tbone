# tbone.vim

Basic tmux support for Vim.

* `:Tmux` lets you call any old `tmux` command (with really good tab
  complete).
* `:Tyank` and `:Tput` give you direct access to tmux buffers.
* `:Twrite` sends a chunk of text to another pane.  Give an argument like
  `windowtitle.2`, `top-right`, or `last`, or let it default to the previously
  given argument.
* `:Tattach` lets you use a specific tmux session from outside of it.

Would you like to paste a shell command into another pane over and over again?
I am sorry but you will have to install one of the 300 other Vim plugins for
tmux.

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/tpope/vim-tbone.git

Once help tags have been generated, you can view the manual with
`:help tbone`.

## Self-Promotion

Like tbone.vim?  Follow the repository on
[GitHub](https://github.com/tpope/vim-tbone) and vote for it on
[vim.org](http://www.vim.org/scripts/script.php?script_id=4488).  And if
you're feeling especially charitable, follow [tpope](http://tpo.pe/) on
[Twitter](http://twitter.com/tpope) and
[GitHub](https://github.com/tpope).

## License

Copyright © Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
