function skc
    set -g -x KUBECONFIG ~/.kube/$argv[1]
end

complete -x -c skc -a '(find ~/.kube -maxdepth 1 -type f -printf "%f\n")'
