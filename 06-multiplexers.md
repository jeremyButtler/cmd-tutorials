# Goal:

Learn how to use tmux to split terminals, detach sessions,
  reattach sessions, and copy and paste.

# Intro

Multiplexers allow you to split a single terminal into
  multiple terminals. This allows you to have your notes
  on one half of the terminal and you analysis on the
  other side. They have made my life more easy. I hope
  they can do the same for you.

Often times a multiplexer will include a copy and paste
  buffer. This can be used to view your history or copy
  and paste commands into your notes.

Another use of some of the more complex multiplexers comes
  in when you are running an analysis on a remote machine.
  You can detach the session, which allows you to log off
  the machine and still keep the analysis running. When
  the analysis is done you can reattach the session.

The two more common multiplexers are screen and tmux.
  Screen is often the default multiplexer on Linux.
  However, I find tmux to be a bit more useful to me.

For Linux and Mac, install tmux. Unless you want to try
  and learn screen. For both multiplexers I will list some
  of the common commands. I expect you to try them and get
  used to them.

For screen on Mac. The screen on Mac is older and does not
  have the vertical split command. So, if you plan to use
  screen On Mac, then install screen by home brew.

# Basic overview

For screen and tmux you input commands by first hitting
  an escape key. For tmux the default is control b. For
  screen the default is control a. After hitting the
  escape key you can provide the next key to run a
  command.

For both tmux and screen you can get a short list of
  commands by using `<escape_key> ?`, were `<escape_key>`
  is the multiplexers escape key..

## configuration files

I often find that I do not like the default escape key for
  either screen or tmux. Both escape keys clash with
  command line hotkeys. Screen's control a is go to the
  start of the line. Tmux's control b is go back one
  character. In both multiplexers you can hit the escape
  key twice to send the command to the terminal. However,
  this is a pain.

Instead I often change the escape key in a configuration
  file. The configuration file allows you to change the
  default key  bindings. For screen it is `.screenrc` and
  for tmux it is `.tmux.conf`. Both of these files are in
  your home directory.

From others I have learned that control t is not often
  used as a keybinding in most programs. So, it is a
  mostly safe key to use as an escape key.

## tmux

### tmux config file

Here is my tmux configuration file (`~/.tmux.conf`)

```
unbind C-b              # remove the control b key binding
                        #   in this case remove from
                        #   being an escape key

set -g prefix C-t       # set control t as the escape key
bind C-t send-prefix    # have control t control t send a
                        # control t

# this sets the keybindings for copy and paste. I prefer
#  vim key bindings.
set-option -g mode-keys vi
```

### using tmux

You can start a tmux session with tmux.

Tmux works by tabs. Each tab has at least one terminal,
  which you can split into multiple terminals with
  hotkeys. Once a terminal is closed the spilt is removed.

Here are some basic commands for tmux.

- For help do `C-t ?`
- Create a new tab do `C-t c`
- To split the tab vertically do `C-t %`.
- To split the tab  horizontally do `C-t "`.
- Move to tab number-x `C-t <tab_number>`
  - To move between tabs to `C-t n` and `C-t p`
- To copy do `C-t [`
  - Press space to set the start of the selection, then
    move down/across until you get your selection
  - Once you have your selection hit enter to copy
    - You can quite with escape or q
- To paste copied text do `C-t ]`
  - you can paste into nano with this
- You can move between terminals in a tab with `C-t o`
- You can move terminals in a tab around with `C-t {` and
  `C-t }`

To detach a tmux session do `C-t C-d`. To reattach a
  session do `tmux attach`.

## screen

### screen config file

Here is my screen configuration file (`~/.screenrc`)

```
# Change escape key to ctrl-t
escape ^Tt
bindkey "\024" command

# key bindings allowing you to jump between windows
bind k focus up
bind j focus down
bind h focus left
bind l focus right

# remove start up message
startup_message off

# Set up hard status line (date/time/terminals). I found
#   this command on stack overflow
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %d/%m %{W}%c %{g}]'
```

### using screen

You can start a screen session using screen.

Screen uses the concept of windows and panes. Were a pane
  is a terminal. Each window represents a place were a
  pane (terminal) can be put. You can swap out pains at
  any time.

Here are some basic commands for screen.

- For help do `C-t ?`
- To split the window vertically do `C-t |`.
- To split the window horizontally do `C-t S`.
  - The `S` must be a uppercase S
- Create a pane with `C-t c`
- Move pane (terminal) x to the window you are on
  `C-t <pane_number>`
  - You can also use `C-t n` and `C-t p` to move to the
    next (n) and previous (p) terminals
- To copy do `C-t [`
  - Press space to set the start of the selection, then
    move down/across until you get your selection
  - Once you have your selection hit enter to copy
    - You can quite with escape or q
- To paste copied text do `C-t ]`
  - you can paste into nano with this
- Movement between windows (from my configuration file)
  - To move to the window to the right do `C-t l`
  - To move to the window to the left do `C-t h`
  - To move to the window above do `C-t k`
  - To move to the window beneath do `C-t j`

You can remove a window by doing `C-t X` (the X must be
  uppercase X).

To detach a screen session (all panes and windows) do
  `C-t C-d`. To reattach a session do `screen -r`. If you
  have multiple sessions `screen -r` will list the
  sessions by id. Do `screen -r <id>` to pick a session to
  attach.

# Notes

At this point you should be able to figure out how to
  use a multiplexer. It will take time to get used to the
  commands for a multiplexer. However, once learned they
  will make your life much easier.
