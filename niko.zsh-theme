# Niko Oh My ZSH Theme

function is_ssh_session() {
  if [ -n "$SSH_CONNECTION" ]; then
    echo "%F{213}ssh%f " # Light pink (213) for SSH indicator
  fi
}

function is_docker_container() {
  if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    echo "%F{86}docker%f " # Light blue (86) for Docker indicator
  elif grep -qE '(docker|containerd)' /proc/1/cgroup 2>/dev/null; then
    echo "%F{86}docker%f " # Light blue (86) for Docker indicator
  fi
}

function is_failed() {
  if [ -n "$ELAPSED_TIME" ] && [[ $LAST_STATUS -ne 0 ]]; then
    echo "%B%F{196}Exit $LAST_STATUS%f%b "
  fi
}

function check_dir_access() {
  if [ ! -w "$PWD" ]; then
    echo "%F{31}∅%f " # Red (31) for no-write-access indicator
  fi
}

function context() {
  if [[ $UID -eq 0 ]]; then
    echo "%B%F{196}%n%f%b@%F{208}%m%f " # Bold red (196) for root, orange (208) for hostname
  else
    echo "%F{45}%n%f@%F{208}%m%f " # Cyan (45) for normal user, orange (208) for hostname
  fi
}

function format_path() {
  local p="${PWD/#$HOME/~}"
  if [[ $p == "/" || $p == "~" ]]; then
    echo "%B%F{39}${p}%f%b " # Blue (39) for root or home directory
  else
    local parent="${p%/*}"
    local last="${p##*/}"
    if [[ $parent == "~" ]]; then
      echo "%F{39}~/%B%F{39}${last}%f%b "
    else
      echo "%F{31}${parent}%F{39}/%B%F{39}${last}%f%b " # Blue (31) for parent, blue (39) for last segment
    fi
  fi
}

function is_failed() {
  if [ -n "$ELAPSED_TIME" ] && [[ $LAST_STATUS -ne 0 ]]; then
    echo "%B%F{196}Exit $LAST_STATUS%f%b "
  fi
}

function execution_time() {
  if [ -n "$ELAPSED_TIME" ]; then
    local total_seconds=$(printf '%.0f' $ELAPSED_TIME)
    local milliseconds=$(printf '%.0f' $(awk -v et="$ELAPSED_TIME" 'BEGIN {print (et - int(et)) * 1000}'))
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))

    local time_output=""
    ((hours > 0)) && time_output+="${hours}h "
    ((minutes > 0)) && time_output+="${minutes}m "
    ((seconds > 0)) && time_output+="${seconds}s "
    ((milliseconds > 0)) && time_output+="${milliseconds}ms"

    if [ -n "$time_output" ]; then
      echo "%F{222}⏱ ${time_output}%f " # Yellow (222) for elapsed time
    fi
  fi
}

function preexec_fn() {
  export START_TIME=$EPOCHREALTIME
}

function precmd_fn() {
  LAST_STATUS=$?

  if [ -n "$START_TIME" ]; then
    export ELAPSED_TIME=$(awk -v start="$START_TIME" -v end="$EPOCHREALTIME" 'BEGIN {print end - start}')
  else
    unset ELAPSED_TIME
  fi

  unset START_TIME
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec preexec_fn
add-zsh-hook precmd precmd_fn

function prompt_command() {
  local prompt="$(is_failed)$(execution_time)"

  if [ -n "$prompt" ]; then
    prompt+=$'\n\n'
  fi

  prompt+="$(is_ssh_session)$(is_docker_container)"
  prompt+="$(context)"
  prompt+="$(check_dir_access)$(format_path)"

  echo "$prompt"
}

PROMPT='$(prompt_command)'
PROMPT+=$'$(git_prompt_info)\n'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{76}" # Green (76) for Git status
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{178} *%f" # Yellow (178) for dirty repo
ZSH_THEME_GIT_PROMPT_CLEAN=""
