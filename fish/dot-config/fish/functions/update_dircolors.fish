function update_dircolors
    if not command -q dircolors
        echo "dircolors not found" >&2
        return 1
    end

    set -l config ~/.config/dircolors
    if not test -f $config
        echo "$config not found" >&2
        return 1
    end

    set -Ux LS_COLORS (dircolors -b $config | string match -r "^LS_COLORS='(.*)'" --groups-only)
end
