# misdreavus-session

*because i had to wrap the built-in session stuff with extra things*

## design ideas

* commands that wrap extra things around `:mksession`
* `User` autocmd `SessionSavePre` that allows plugins to do special things before a session is saved
* assumption: if a plugin has a `SessionSavePre` command, it reacts to the built-in
  `SessionLoadPost` autocmd and `SessionLoad` variable to do things during a session load
* bonus: prompt during quit if `v:this_session` is set and we're not saving back to it?
