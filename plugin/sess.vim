" misdreavus-session: crude session management
" (c) 2020 QuietMisdreavus

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

function! s:save_session(name)
    if a:name == ""
        let name = g:misdreavus_session_default
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

augroup MisdreavusSession
    autocmd User SessionSavePre let s:session_saved = 1
    autocmd BufAdd,BufDelete,BufNew,BufUnload,BufWipeout,BufEnter * unlet! s:session_saved
    autocmd WinNew,WinEnter,WinLeave * unlet! s:session_saved
    autocmd VimLeavePre * call <sid>auto_save()
augroup END

command -nargs=? -complete=file SaveSession call <sid>save_session(<q-args>)
