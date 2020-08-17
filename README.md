# misdreavus-session

*it's `:mksession`, with some extra tweaks*

`misdreavus-session` is a barebones session-management plugin that wraps the builtin `:mksession`
command with some extra tweaks.

Rather than centralizing session files into a configurable directory (see [xolox/vim-session] for
that), misdreavus-session assumes that your sessions will be saved in the directory that they're
relevant for. It provides an auto-save and auto-load functionality to interact with a session file
in the current directory.

[xolox/vim-session]: https://github.com/xolox/vim-session

In addition, misdreavus-session provides an autocmd event that it fires before it saves a session
file. This can be used to integrate with plugins. For example, [misdreavus-mru] uses this to save
and load MRU lists in the session file.

[misdreavus-mru]: https://github.com/QuietMisdreavus/misdreavus-mru

## installing

Point your plugin manager to `QuietMisdreavus/misdreavus-session`, or clone it into your `bundle/`
or `pack/` directory, or however you manage Vim scripts.

## commands

### `:SaveSession`

`:SaveSession [filename]` saves the current session to the given filename. If no filename is given,
it first checks whether a session was loaded previously (using the builtin `v:this_session`
variable).  If no session was detected, the value of `g:misdreavus_session_default` is used. Before
saving, it fires the `User SessionSavePre` autocmd event, for plugins to save their state into the
session file.

### `:SessionQuit`

`:SessionQuit[!] [filename]` calls `:SaveSession` with the given argument (to save the current
session), then quits Vim. If a `!` is given to `:SessionQuit`, it will be passed to the `:q`
command.

### `:LoadSession`

`:LoadSession [filename]` sources a session from the given filename. If no filename is given, the
value of `g:misdreavus_session_default` is used.

## config

### `g:misdreavus_session_default`

`g:misdreavus_session_default` is the default filename used when saving or loading sessions. By
default, this is set to `'Session.vim'`, the default for the `:mksession` command.

The author recommends you add this filename to a global source-control ignore list, to prevent
accidentally adding session files to repositories.

### `g:misdreavus_session_autosave`

`g:misdreavus_session_autosave` controls whether misdreavus-session attempts to save back to a
session file when Vim is exited. There are three possible values:

* `'no'` (default): The session will not be saved on exit.
* `'yes'`: The session will be automatically saved when Vim is exited.
* `'prompt'`: If the session has not just been saved, misdreavus-session will prompt on exit to ask
  whether you want to save the session.

Regardless of the value of this variable, if no session has been loaded (i.e. `v:this_session` is
empty), then the auto-save code will be skipped. (This is helpful for when Vim is opened for git
commit messages, for example.)

This setting is case-insensitive.

### `g:misdreavus_session_autoload`

`g:misdreavus_session_autoload` controls whether misdreavus-session attempts to automatically load a
session file from a file named with the value of `g:misdreavus_session_default` in the current
directory when Vim is started. There are three possible values:

* `'no'` (default): No session will be automatically loaded on startup.
* `'yes'`: If a session file exists in the current directory, misdreavus-session will source it on
  startup.
* `'prompt'`: If a session file exists in the current directory, misdreavus-session will prompt on
  startup to ask whether you want to load the session.

Regardless of the value of this setting, if a session was specified on the command-line (with the
`-S` parameter), or if an argument list was given (by passing filenames to Vim on the command-line),
then the auto-load code will be skipped. (This is helpful for when Vim is opened for git commit
messages, for example.)

This setting is case-insensitive.

## events

### `SessionSavePre`

When misdreavus-session saves a session, whether manually with `:SaveSession` or automatically, it
fires this autocmd event, so that other plugins can save data in the session file. To run autocmds
after a session has been loaded, use the builtin `SessionLoadPost` event.

## license

misdreavus-session is licensed under the Mozilla Public License, version 2.0. See the LICENSE file
for details.
