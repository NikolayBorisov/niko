# Niko Oh My ZSH Theme

# Check if session is SSH
function is_ssh_session() {
  if [ -n "$SSH_CONNECTION" ]; then
    echo "%F{213}ssh%f "  # Light pink (213) for SSH indicator
  fi
}

# Check if inside a Docker container
function is_docker_container() {
  if [ -f /.dockerenv ] || [ -f /run/.containerenv ] || grep -qE "(docker|lxc)" /proc/1/mountinfo 2>/dev/null; then
    echo "%F{86}docker%f "  # Light blue (86) for Docker indicator
  fi
}

# Display error status with gradient effect
function is_failed() {
  local gradient=""
  local colors=(196 160 124 88 52)  # Gradient from red to dark red
  for color in "${colors[@]}"; do
    gradient+="%F{$color}─%f"
  done
  echo $'%(?::%B%F{196}───────────────────%f%b%B'"${gradient}"'%b\n)'
}

# Check if current directory is writable
function check_dir_access() {
  if [ ! -w "$PWD" ]; then
    echo "%F{31}∅%f "  # Red (31) for no-write-access indicator
  fi
}

# Show user@host context with color for root and normal users
function context() {
  if [[ $UID -eq 0 ]]; then
    echo "%B%F{196}%n%f%b@%F{208}%m%f "  # Bold red (196) for root, orange (208) for hostname
  else
    echo "%F{45}%n%f@%F{208}%m%f "  # Cyan (45) for normal user, orange (208) for hostname
  fi
}

# Format and colorize the current path
function format_path() {
  local p="${PWD/#$HOME/~}"
  if [[ $p == "/" || $p == "~" ]]; then
    echo "%F{39}${p}%f "  # Blue (39) for root or home directory
  else
    local parent="${p%/*}" 
    local last="${p##*/}"
    if [[ $parent == "~" ]]; then
      echo "%F{39}~/%B%F{39}${last}%f%b "
    else
      echo "%F{31}${parent}%F{39}/%B%F{39}${last}%f%b "  # Red (31) for parent, blue (39) for last segment
    fi
  fi
}

# Pre-execution hook to record start time of a command
function preexec_fn() {
  export START_TIME=$EPOCHREALTIME
}

# Post-command hook to display command execution time
function precmd_fn() {
  if [ -n "$START_TIME" ]; then
    local elapsed_time=$(awk -v start="$START_TIME" -v end="$EPOCHREALTIME" 'BEGIN {print end - start}')
    if (( $(awk -v et="$elapsed_time" 'BEGIN {print (et > 0.5)}') )); then
      local hours minutes seconds milliseconds time_output=""
      
      read hours minutes seconds milliseconds < <(
        awk -v et="$elapsed_time" 'BEGIN {
          h = int(et / 3600);
          m = int((et % 3600) / 60);
          s = int(et % 60);
          ms = int((et - int(et)) * 1000);
          print h, m, s, ms;
        }'
      )
      
      (( hours > 0 )) && time_output+="${hours}h "
      (( minutes > 0 )) && time_output+="${minutes}m "
      (( seconds > 0 )) && time_output+="${seconds}s "
      (( milliseconds > 0 )) && time_output+="${milliseconds}ms"
      
      [ -n "$time_output" ] && print -P "%F{222}⏱ ${time_output}%f"  # Yellow (222) for elapsed time
    fi
  fi
  unset START_TIME
}

# Attach hooks for preexec and precmd
autoload -Uz add-zsh-hook
add-zsh-hook preexec preexec_fn
add-zsh-hook precmd precmd_fn

# Define prompt with indicators and Git status
PROMPT=$'$(is_failed)\n'
PROMPT+='$(is_ssh_session)$(is_docker_container)'
PROMPT+='$(context)'
PROMPT+='$(check_dir_access)$(format_path)'
PROMPT+=$'$(git_prompt_info)\n'

# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%F{76}"  # Green (76) for Git status
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{178} ✗%f"  # Yellow (178) for dirty repo
ZSH_THEME_GIT_PROMPT_CLEAN="%F{76}%f"  # Green (76) for clean repo
