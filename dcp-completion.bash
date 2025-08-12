#!/bin/bash

# dcp bash completion script
# This script provides intelligent tab completion for the dcp command

_dcp_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # DCP cache file location
    local cache_file="${HOME}/.cache/dcp/hosts"

    # Available options
    opts="--help --list-hosts --add-host --remove-host --clear-cache -r -p -P -q -v -C -4 -6"

    # Special case: if previous word is --add-host or --remove-host
    if [[ "$prev" == "--add-host" || "$prev" == "--remove-host" ]]; then
        if [[ -f "$cache_file" ]]; then
            COMPREPLY=($(compgen -W "$(cat "$cache_file" 2>/dev/null)" -- "$cur"))
        fi
        return 0
    fi

    # If current word starts with a dash, complete with options
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
    fi

    # Check if we're completing a remote path (contains @)
    if [[ "$cur" == *@* ]]; then
        # Extract the part before @ for user completion
        local user_part="${cur%%@*}"
        local host_part="${cur#*@}"

        # If there's a colon, we're completing a path on the remote host
        if [[ "$host_part" == *:* ]]; then
            # For now, just complete what the user has typed
            # In a more advanced version, we could SSH to complete remote paths
            COMPREPLY=("$cur")
            return 0
        fi

        # Complete with cached hosts
        if [[ -f "$cache_file" ]]; then
            local hosts
            hosts=$(cat "$cache_file" 2>/dev/null)

            # Filter hosts that match the current input
            local matching_hosts=""
            for host in $hosts; do
                if [[ "$host" == "$user_part@"* ]]; then
                    # Extract just the hostname part
                    local hostname="${host#*@}"
                    matching_hosts="$matching_hosts $user_part@$hostname:"
                fi
            done

            if [[ -n "$matching_hosts" ]]; then
                COMPREPLY=($(compgen -W "$matching_hosts" -- "$cur"))
            else
                # If no exact user match, try to complete with any cached host
                # but replace the user part
                for host in $hosts; do
                    local hostname="${host#*@}"
                    matching_hosts="$matching_hosts $user_part@$hostname:"
                done
                COMPREPLY=($(compgen -W "$matching_hosts" -- "$cur"))
            fi
        fi

        return 0
    fi

    # Check if current word looks like it could be the start of a user@host pattern
    if [[ "$cur" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        if [[ -f "$cache_file" ]]; then
            local hosts
            hosts=$(cat "$cache_file" 2>/dev/null)

            # Find hosts that start with the current user prefix
            local matching_completions=""
            for host in $hosts; do
                if [[ "$host" == "$cur"* ]]; then
                    matching_completions="$matching_completions $host:"
                fi
            done

            if [[ -n "$matching_completions" ]]; then
                COMPREPLY=($(compgen -W "$matching_completions" -- "$cur"))
                return 0
            fi
        fi
    fi

    # Default file completion for local files
    COMPREPLY=($(compgen -f -- "$cur"))

    return 0
}

# Function to handle completion for different shells
_dcp_setup_completion() {
    # Check if we're in bash
    if [[ -n "$BASH_VERSION" ]]; then
        complete -F _dcp_completion dcp
    fi
}

# Auto-setup completion when sourced
_dcp_setup_completion

# Provide a function to manually setup completion
setup_dcp_completion() {
    _dcp_setup_completion
    echo "DCP completion setup complete!"
}

# Utility function to add completion to shell profile
install_dcp_completion() {
    local completion_script="$1"
    local shell_profile=""

    # Detect shell and appropriate profile file
    if [[ -n "$BASH_VERSION" ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            shell_profile="$HOME/.bashrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            shell_profile="$HOME/.bash_profile"
        fi
    elif [[ -n "$ZSH_VERSION" ]]; then
        shell_profile="$HOME/.zshrc"
    fi

    if [[ -n "$shell_profile" ]]; then
        echo "# DCP completion" >> "$shell_profile"
        echo "source \"$completion_script\"" >> "$shell_profile"
        echo "Completion installed to $shell_profile"
        echo "Please restart your shell or run: source $shell_profile"
    else
        echo "Could not detect shell profile file."
        echo "Please manually add this line to your shell profile:"
        echo "source \"$completion_script\""
    fi
}
