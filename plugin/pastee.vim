" ===================================================================
" File: pastee.vim
" Author: Ferus <ferus@pyboard.net> <ircs://irc.datnode.net/#hacking>
" Version: 0.2
" License: WTFPL
" Desc: Posts the current buffer/selection to pastee.org
" Requires: Vim compiled with Python and Requests HTTP Lib
"   https://github.com/kennethreitz/requests
"
" Config Variables:
"   g:pastee_ttl
"     Default time to live for pastee
"   g:pastee_key
"     Default key to encrypt post with
"   g:pastee_usebrowser
"     Opens browser if set
"   g:pastee_webbrowser
"     The browser to open if above is true
"     See http://docs.python.org/library/webbrowser.html
"   g:pastee_printurl
"     Prints url in vim if set
"
" Installing:
"   Place in ~/.vim/plugin/ (UNIX)
"   Or where ever else is necessary for other platforms
"   Or where ever and source the file
"
" Example Config:
"   let g:pastee_key=secretkey
"   let g:pastee_ttl=86400
"   let g:pastee_usebrowser=1
"   let g:pastee_webbrowser='firefox'
"   let g:pastee_printurl=1
"
"
" Default Bindings:
"   nmap <silent> <F2> :1,$Pastee<CR>
"   xmap <silent> <F2> :Pastee<CR>

if !has('python')
	echo "Error: Requires vim compiled with python support"
	finish
endif

if !exists("g:pastee_ttl")
	let g:pastee_ttl="86400"
endif

if !exists("g:pastee_key")
	let g:pastee_key=""
endif

if !exists("g:pastee_usebrowser")
	let g:pastee_usebrowser=0
endif

if !exists("g:pastee_webbrowser")
	let g:pastee_webbrowser=""
endif

if !exists("g:pastee_printurl")
	let g:pastee_printurl=1
endif

let g:pastee_filetype=expand("%:e")

function! Pastee() range
	let l:text = getline(a:firstline, a:lastline)

python << EOF
import re
import vim
import webbrowser
text = "\n".join(vim.eval("l:text"))
lexer = vim.eval("g:pastee_filetype")
key = vim.eval("g:pastee_key")
ttl = vim.eval("g:pastee_ttl")
usebrowser = vim.eval("g:pastee_usebrowser")
browser = vim.eval("g:pastee_webbrowser")
printurl = vim.eval("g:pastee_printurl")
try:
	browser = webbrowser.get(browser)
except Exception as e:
	browser = webbrowser.get(None)

try:
	import requests
except ImportError as e:
	print("Requests must be installed to use this.")

def post(text, lexer, key, ttl):
	headers = {"Content-Type": "application/x-www-form-urlencoded"
		,"Accept": "text/plain"}
	data = {"lexer": lexer
		,"content": text
		,"ttl": ttl}
	if key != "":
		data["encrypt"] = "checked"
		data["key"] = key
	try:
		req = requests.post("https://pastee.org/submit"
			,headers=headers
			,data=data)
		if req.status_code != 200:
			# Error'd
			req.raise_for_status()
	except (requests.ConnectionError, requests.HTTPError) as e:
		print(repr(e))

	paste = "https://pastee.org/" + \
		re.findall("<h1>paste id <code>(\w+)</code>(?:.*)</h1>", req.text)[0]
	return paste

url = post(text, lexer, key, ttl)
if usebrowser:
	browser.open_new_tab(url)
if printurl:
	print(url)
EOF
" Unlet var to free memory
if exists("l:text")
	unlet! l:text
endif
endfunction

" Register :Pastee as a command
command! -buffer -range Pastee <line1>,<line2>:call Pastee()
" bind <F2> to `call Pastee(<text>)` for normal and visual modes
nmap <silent> <F2> :1,$Pastee<CR>
xmap <silent> <F2> :Pastee<CR>
