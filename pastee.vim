" ===================================================================
" File: pastee.vim
" Author: Ferus <ferus@pyboard.net> <ircs://irc.datnode.net/#hacking>
" Version: 0.1
" License: WTFPL
" Desc: Posts the current buffer/selection to pastee.org
" Requires: Python and Requests HTTP Lib
"
" Config Variables:
" g:pastee_ttl
"   Default time to live for pastee
" g:pastee_key
"   Default key to encrypt post with
" g:pastee_usebrowser
"   Opens browser if set
" g:pastee_webbrowser
"   The browser to open if above is true
"   See http://docs.python.org/library/webbrowser.html
"
" Example Config (~/.vimrc):
" let g:pastee_key=secretkey
" let g:pastee_ttl=86400
" let g:pastee_usebrowser=1
" let g:pastee_webbrowser='firefox'
"
" source /home/`user`/.vim/autoload/pastee.vim
" " bind <F2> to `call Pastee(<text>)`
" nmap <F2> :call Pastee()<CR>
" vmap <F2> :call Pastee()<CR>
"

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

let g:pastee_filetype=expand("%:e")

function! Pastee()
let text = getline(line("^"), line("$"))

python << EOF
import re
import vim
import webbrowser
text = "\n".join(vim.eval("text"))
lexer = vim.eval("g:pastee_filetype")
key = vim.eval("g:pastee_key")
ttl = vim.eval("g:pastee_ttl")
usebrowser = vim.eval("g:pastee_usebrowser")
browser = vim.eval("g:pastee_webbrowser")
try:
	browser = webbrowser.get(browser)
except Exception as e:
	browser = webbrowser.get(None)

try:
	import requests
except ImportError as e:
	pass

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
	if not browser.open_new_tab(url):
		print(url)

EOF
endfunction
