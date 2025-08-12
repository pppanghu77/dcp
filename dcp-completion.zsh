#compdef dcp

# dcp zsh completion script

_dcp() {
    local state line context
    local cache_file="${HOME}/.cache/dcp/hosts"
    local alias_file="${HOME}/.cache/dcp/aliases"

    _arguments -C \
        '(--help -h)'{--help,-h}'[Show help information]' \
        '--list-hosts[List cached hosts]' \
        '--add-host[Add host to cache]:host:_dcp_hosts' \
        '--remove-host[Remove host from cache]:host:_dcp_cached_hosts' \
        '--clear-cache[Clear all cached hosts]' \
        '--add-alias[Add host alias]:alias name: :host:_dcp_hosts' \
        '--remove-alias[Remove host alias]:alias:_dcp_aliases' \
        '--list-aliases[List all aliases]' \
        '-r[Recursively copy entire directories]' \
        '-p[Preserve modification times, access times, and modes]' \
        '-P[Use a specific port]:port:' \
        '-q[Quiet mode]' \
        '-v[Verbose mode]' \
        '-C[Compress data in transit]' \
        '-4[Force IPv4 addresses only]' \
        '-6[Force IPv6 addresses only]' \
        '*:file:_dcp_files_or_hosts'
}

# Function to complete cached hosts
_dcp_cached_hosts() {
    if [[ -f "$cache_file" ]]; then
        local hosts
        hosts=(${(f)"$(cat "$cache_file" 2>/dev/null)"})
        _describe 'cached hosts' hosts
    fi
}

# Function to complete aliases
_dcp_aliases() {
    if [[ -f "$alias_file" ]]; then
        local aliases
        aliases=(${(f)"$(cut -d'=' -f1 "$alias_file" 2>/dev/null)"})
        _describe 'aliases' aliases
    fi
}

# Function to complete hosts (for adding new ones)
_dcp_hosts() {
    _alternative \
        'hosts:cached hosts:_dcp_cached_hosts' \
        'manual:manual entry:(user@hostname)'
}

# Function to complete files or remote hosts
_dcp_files_or_hosts() {
    local cache_file="${HOME}/.cache/dcp/hosts"
    local alias_file="${HOME}/.cache/dcp/aliases"

    # If the current word starts with @, we're dealing with an alias
    if [[ "$PREFIX" == @* ]]; then
        local alias_prefix="${PREFIX#@}"

        # If there's already a colon, complete with remote path
        if [[ "$alias_prefix" == *:* ]]; then
            _message "remote path"
            return 0
        fi

        # Complete with aliases
        if [[ -f "$alias_file" ]]; then
            local aliases completions
            aliases=(${(f)"$(cut -d'=' -f1 "$alias_file" 2>/dev/null)"})
            completions=()

            for alias_name in $aliases; do
                if [[ "$alias_name" == "$alias_prefix"* ]]; then
                    completions+=("@$alias_name:")
                fi
            done

            if [[ ${#completions[@]} -gt 0 ]]; then
                _describe 'aliases' completions -S ''
                return 0
            fi
        fi

        _message "alias"
        return 0
    fi

    # If the current word contains @ but doesn't start with @, we're dealing with user@host
    if [[ "$PREFIX" == *@* && "$PREFIX" != @* ]]; then
        local user_part="${PREFIX%%@*}"
        local host_part="${PREFIX#*@}"

        # If there's already a colon, complete with remote path
        if [[ "$host_part" == *:* ]]; then
            # For now, just accept what the user has typed
            # In future versions, could implement remote path completion
            _message "remote path"
            return 0
        fi

        # Complete with cached hosts
        if [[ -f "$cache_file" ]]; then
            local hosts completions
            hosts=(${(f)"$(cat "$cache_file" 2>/dev/null)"})
            completions=()

            for host in $hosts; do
                if [[ "$host" == "$user_part@"* ]]; then
                    local hostname="${host#*@}"
                    completions+=("$user_part@$hostname:")
                fi
            done

            # If no exact user match, provide completions with the current user
            if [[ ${#completions[@]} -eq 0 ]]; then
                for host in $hosts; do
                    local hostname="${host#*@}"
                    completions+=("$user_part@$hostname:")
                done
            fi

            if [[ ${#completions[@]} -gt 0 ]]; then
                _describe 'remote hosts' completions
                return 0
            fi
        fi

        _message "user@hostname:"
        return 0
    fi

    # Check if current word could be start of user@host or alias
    if [[ "$PREFIX" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        local all_completions=()

        # Add cached hosts that match
        if [[ -f "$cache_file" ]]; then
            local hosts
            hosts=(${(f)"$(cat "$cache_file" 2>/dev/null)"})

            for host in $hosts; do
                if [[ "$host" == "$PREFIX"* ]]; then
                    all_completions+=("$host:")
                fi
            done
        fi

        # Add aliases that match (with @ prefix)
        if [[ -f "$alias_file" ]]; then
            local aliases
            aliases=(${(f)"$(cut -d'=' -f1 "$alias_file" 2>/dev/null)"})

            for alias_name in $aliases; do
                if [[ "$alias_name" == "$PREFIX"* ]]; then
                    all_completions+=("@$alias_name:")
                fi
            done
        fi

        if [[ ${#all_completions[@]} -gt 0 ]]; then
            _alternative \
                'files:local files:_files' \
                'hosts-and-aliases:hosts and aliases:((${all_completions[@]}))'
            return 0
        fi
    fi

    # Default to file completion
    _files
}

# Set up the completion
_dcp "$@"
