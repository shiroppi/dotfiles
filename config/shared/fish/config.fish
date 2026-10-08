# environment variables
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx PAGER less
set -gx BUN_INSTALL "$HOME/.bun"
set -gx DENO_INSTALL "$HOME/.deno"

# paths
fish_add_path ~/.bin
fish_add_path ~/bin
fish_add_path ~/.local/bin
fish_add_path ~/go/bin
fish_add_path $BUN_INSTALL/bin
fish_add_path $DENO_INSTALL/bin

if test (uname) = Darwin
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
    fish_add_path /opt/homebrew/opt/openjdk/bin
    fish_add_path $HOME/.nodebrew/current/bin
    fish_add_path /opt/homebrew/opt/llvm/bin

    set -gx LDFLAGS -L/opt/homebrew/opt/llvm/lib
    set -gx CPPFLAGS -I/opt/homebrew/opt/llvm/include
end

# aliases

# essentials
alias dc cd
alias sl exa
alias ls exa
alias relogin "exec $SHELL -l"

# usability
alias lg lazygit

# custom functions
while read -l line
    string match -q -r '^\s*#' $line; and continue
    string match -q -r '^\s*$' $line; and continue

    set -l kv (string split -m 1 = $line)
    set -gx $kv[1] $kv[2]
end <.env

# starship
source (starship init fish --print-full-init | psub)
