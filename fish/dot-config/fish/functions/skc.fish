function skc
    set -g -x KUBECONFIG ~/.kube/config-$argv[1].yml
end

complete -x -c skc -a '(for f in ~/.kube/config-*.yml; string replace -r "^.*/config-(.*)\\.yml\$" \'$1\' $f; end)'
