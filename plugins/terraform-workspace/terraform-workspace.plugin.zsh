# Global variables to cache the last known .terraform directory and its corresponding workspace name
__TERRAFORM_WORKSPACE_CACHE=""
__TERRAFORM_DIRECTORY_CACHE=""

# Function to find the .terraform directory in the current or any parent directory
__find_terraform_directory() {
  local current_dir="$PWD"
  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "${current_dir}/.terraform" ]]; then
      echo "${current_dir}/.terraform"
      return
    fi
    current_dir="$(dirname "$current_dir")"
  done
}

# Function to update the Terraform workspace prompt based on the current working directory, utilizing the global cache variables
__update_terraform_workspace_prompt() {
  local terraform_dir="$(__find_terraform_directory)"
  if [[ -n "$terraform_dir" && "$terraform_dir" != "$__TERRAFORM_DIRECTORY_CACHE" ]]; then
    __TERRAFORM_DIRECTORY_CACHE="$terraform_dir"
    local workspace="$(terraform -chdir="$(dirname "${terraform_dir%/}")" workspace show 2>/dev/null)"
    __TERRAFORM_WORKSPACE_CACHE="$workspace"
  elif [[ -z "$terraform_dir" ]]; then
    __TERRAFORM_DIRECTORY_CACHE=""
    __TERRAFORM_WORKSPACE_CACHE=""
  fi
}

# Hooks to call the update function when the working directory changes or before each prompt is displayed
autoload -Uz add-zsh-hook
add-zsh-hook chpwd __update_terraform_workspace_prompt
add-zsh-hook precmd __update_terraform_workspace_prompt

# If you notice, aliases are bounded to each other
# Why? Gives the freedom to override the lower levels and to affect all of them
# e.g.: alias tfi=terraform init -no-color -reconfigure

alias tf=terraform

alias tfi='tf init'

alias tfp='tf plan'
alias tfip='tfi && tfp'

alias tfa='tf apply'
alias tfia='tfi && tfa'

alias tfd='tf destroy'
alias tfid='tfi && tfd'

# DANGER zone
alias tfa!='tfa -auto-approve'
alias tfia!='tfi && tfa!'
# DANGER++!!
alias tfd!='tfd -auto-approve'
alias tfid!='tfi && tfd!'

alias tfc='tf console'
alias tfg='tf graph'
alias tfc='tf console'
alias tfget='tf get'
alias tfimp='tf import'
alias tfo='tf output'
alias tfprov='tf providers'
alias tfpp='tf push'
alias tfr='tf refresh'
alias tfs='tf show'
alias tfst='tf state'
alias tft='tf taint'
alias tfunt='tf untaint'
alias tfv='tf validate'
alias tfver='tf version'
alias tfw='tf workspace'

complete -o nospace -C $(which terraform) terraform
