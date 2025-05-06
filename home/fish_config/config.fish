if status is-interactive
    # Commands to run in interactive sessions can go here
    fzf --fish | source
    starship init fish | source
    zoxide init fish | source
end
