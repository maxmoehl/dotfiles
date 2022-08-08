# if inside a git repo the following will be done:
#   get the current working directory and the path of the directory the repo is inside
#   store the name of the directory the git repo is in
#   remove the path of the directory the git repo is in from the current wd
#   concatenate the name of the directory the repo is inside and what is left from the removal
#   of the full repo path from the current wd
# 
#   this will essentially create a relative path to the root directory of the repository
# else
#   print the current directory relative to $HOME or the absolute path if outside $HOME
directory() {
  if git rev-parse --is-inside-work-tree &> /dev/null; then
    git_root=$(git rev-parse --show-toplevel)
    current_dir=$(pwd)
    rel_path=(${current_dir#"$git_root"})
    repo_name=(${git_root##*/})
    
    echo "%F{blue}$repo_name$rel_path%f"
  else
    echo "%F{blue}%0~%f"
  fi
}

# if the return status of the last run command is non-zero print the value
return_status() {
  echo "%(?.. %F{red}%?%f)"
}

# adds a host to the beginning of the shell if the shell is a ssh session
prompt_host() {
  if [[ -n "${SSH_CONNECTION}" ]]; then
    echo "%F{red}[$(hostname)]%f"
  fi
}

# adds the current shell level as a prefix
prompt_lvl() {
  LVL=$(( SHLVL - 1 ))
  if [[ "${LVL}" -gt 0 ]]; then
    echo "%F{red}[lvl=${LVL}]%f"
  fi
}

# display a dollar sign or hash according to the current user
prompt_symbol() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "%F{blue}#%f"
  else
    echo "%F{blue}$%f"
  fi
}

prompt_prefix() {
  PREFIX="$(prompt_host)$(prompt_lvl)"
  if [[ -n "${PREFIX}" ]]; then
    echo "${PREFIX} "
  fi
}

# color codes the output from git_promt_info and git_prompt_status
# for more info check the variables below
prompt_git() {
  echo "%F{yellow}$(git_prompt_info)%f$(git_prompt_status)"
}

prompt_git_no_status() {
  echo "%F{yellow}$(git_prompt_info)%f"
}

ZSH_THEME_GIT_PROMPT_ADDED=" %F{yellow}✈%f"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %F{yellow}✱%f"
ZSH_THEME_GIT_PROMPT_AHEAD=" %F{green}↑%f"
ZSH_THEME_GIT_PROMPT_BEHIND=" %F{red}↓%f"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_PREFIX=" "
ZSH_THEME_GIT_PROMPT_SUFFIX=""

# put it all together, only the prompt symbol and a space on the left
PROMPT='$(prompt_prefix)$(prompt_symbol) '

# and information on the directory, git and the return status on the right
# currently the git status is disabled because it is slow as hell
# to re-enable this the two git config options als need to be unset
# RPROMPT='$(directory)$(prompt_git)$(return_status)'
RPROMPT='$(directory)$(prompt_git_no_status)$(return_status)'

