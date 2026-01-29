if status is-interactive
    # Commands to run in interactive sessions can go here
    set -gx EDITOR nvim
    set -gx VISUAL $EDITOR
    fzf --fish | source
    starship init fish | source
    zoxide init fish | source
end
