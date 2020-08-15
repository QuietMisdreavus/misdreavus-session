" misdreavus-session: crude session management
" (c) 2020 QuietMisdreavus

" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at http://mozilla.org/MPL/2.0/.

" the variable `g:misdreavus_session_autosave` controls the 'auto-save' behavior when Vim is exited.
"
" there are three known values:
"
" * 'no' (default): do not save a session when Vim is exited.
" * 'yes': if a session was loaded, save to it when Vim is exited.
" * 'prompt': if a session was loaded, prompt when Vim is exited to ask whether to save back to it.
if !exists('g:misdreavus_session_autosave')
    let g:misdreavus_session_autosave = 'no'
endif

" the variable `g:misdreavus_session_default` controls the default name of the session file. the
" default value is 'Session.vim' (the default for `:mksession`).
if !exists('g:misdreavus_session_default')
    let g:misdreavus_session_default = 'Session.vim'
endif

" the variable `g:misdreavus_session_autoload` controls the 'auto-load' behavior when Vim is
" started.
"
" there are three known values:
"
" * 'no' (default): do not load a session when Vim starts up.
" * 'yes': if vim was started without a `-S` flag or an argument list, and a file with the name
"   given by `g:misdreavus_session_default` exists, load it.
" * 'prompt': if all the above conditions for 'yes' are true, prompt the user to load a session on
"   startup.
if !exists('g:misdreavus_session_autoload')
    let g:misdreavus_session_autoload = 'no'
endif

function! s:save_session(name)
    if a:name == ""
        if empty(v:this_session)
            let name = g:misdreavus_session_default
        else
            let name = v:this_session
        endif
    else
        let name = a:name
    endif

    let v:this_session = fnamemodify(name, ':p')

    doautocmd <nomodeline> User SessionSavePre

    execute "mksession! " .. name
endfunction

function! s:auto_save()
    if exists('v:dying') && v:dying
        return
    endif

    if empty(v:this_session) || exists('s:session_saved')
        return
    endif

    if g:misdreavus_session_autosave == 'no'
        return
    elseif g:misdreavus_session_autosave == 'yes'
        call s:save_session(v:this_session)
    elseif g:misdreavus_session_autosave == 'prompt'
        let resp = confirm('Save session file?', "&Yes\n&No", 1, 'Question')
        if resp == 1
            call s:save_session(v:this_session)
        endif
    endif
endfunction

function! s:load_session(name, silent)
    if empty(a:name)
        let l:name = g:misdreavus_session_default
    else
        let l:name = a:name
    endif

    if !filereadable(l:name) || !filewritable(l:name)
        " there's no session file to load, or the permissions on it are bad
        if !a:silent
            echoerr 'session file "' .. l:name .. '" does not exist'
        endif
        return
    endif

    execute "source " .. l:name
endfunction

function! s:auto_load()
    if index(v:argv, '-S') >= 0
        " if we loaded a session from the command-line, don't bother loading another
        return
    endif

    if argc() > 0
        " if they manually gave files in the argument list, don't bother loading a session, that
        " would wipe that list out
        return
    endif

    let l:autoload = g:misdreavus_session_autoload

    if l:autoload != 'yes' && l:autoload != 'prompt'
        " the user has not set up auto-loading
        return
    endif

    let l:sessname = g:misdreavus_session_default

    if l:autoload == 'prompt' && filereadable(l:sessname) && filewritable(l:sessname)
        let resp = confirm('Load session "' .. l:sessname .. '"?', "&Yes\n&No", 1, "Question")
        if resp != 1
            return
        endif
    endif

    if v:vim_did_enter
        call s:load_session(l:sessname, v:true)
    else
        autocmd VimEnter * ++once ++nested call s:load_session(l:sessname, v:true)
    endif
endfunction

function! MisdreavusSessionStatus()
    return exists('s:session_saved')
endfunction

augroup MisdreavusSession
    autocmd!

    autocmd User SessionSavePre let s:session_saved = 1
    autocmd BufAdd,BufDelete,BufNew,BufWipeout,BufEnter * unlet! s:session_saved
    autocmd WinNew,WinEnter,WinLeave * unlet! s:session_saved
    autocmd VimLeavePre * call <sid>auto_save()
augroup END

command -nargs=? -complete=file SaveSession call <sid>save_session(<q-args>)
command -nargs=0 -bang          SessionQuit SaveSession | q<bang>
command -nargs=? -complete=file LoadSession call <sid>load_session(<q-args>, v:false)

" when the script is loaded, check for whether we should auto-load anything
if v:vim_did_enter
    call s:auto_load()
else
    autocmd VimEnter * ++once ++nested call s:auto_load()
endif
