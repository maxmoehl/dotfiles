function rfc
    set -f rfc_dir ~/.local/share/rfc
    set -f rfc_filename "rfc$argv[1].txt"

    if ! test -d $rfc_dir
        mkdir -p $rfc_dir
    end

    if ! test -f $rfc_dir/$rfc_filename
        curl -fsSo $rfc_dir/$rfc_filename "https://www.rfc-editor.org/rfc/$rfc_filename"
    end

    sed -e '/./,$!d' \
        -e 's#\f$#========================================================================#g' \
        $rfc_dir/$rfc_filename \
        | less -R
end
