# Vimscripts:

## About:

A personal collection of scripts I've written to better the Vim editor.

## License:

[WTFPL]

## Scripts:

1. Pastee.vim

## Installing:

1. Install [Vundle]

2. Add `Bundle 'Ferus/vimscripts'` to your ~/.vimrc

3. Configure

4. Enjoy

### plugins/pastee.vim:

In normal mode, invoking :Pastee pastes the whole buffer.

In visual mode, invoking :Pastee pastes the current selection.

The F2 key is binded by default to :Pastee, you can change it or remove it yourself :)

Requirements: ::

	Vim >= 7.0 Compiled with Python support
	[Requests] - Python HTTP Requests for Humans™

Configuring: ::

	" Default time to live for pastee
	let g:pastee_ttl=86400

	" Default key to encrypt post with
	let g:pastee_key=mykey

	" Opens browser if set
	let g:pastee_usebrowser='firefox'

	" The browser to open if above is true
	" See http://docs.python.org/library/webbrowser.html
	let g:pastee_webbrowser=1

	" Prints url in vim if set
	let g:pastee_printurl=1

Default Keybinds: ::

	nmap <silent> <F2> :1,$Pastee<CR>
	xmap <silent> <F2> :Pastee<CR>


[WTFPL]: http://sam.zoy.org/wtfpl/COPYING
[Vundle]: https://github.com/gmarik/vundle
[Requests]: https://github.com/kennethreitz/requests
