# ~/.bashrc
source ~/.bash_completion
if [ -f ~/.bash_completion ]; then
    . ~/.bash_completion
fi

alias drucken='~/configs/hyprland/skripts/drucken.sh'
alias scrape='conda activate serv && python -m webscraper'
alias ipv6='sudo sysctl net.ipv6.conf.all.disable_ipv6='

alias chrome='/home/admin/.conda/envs/serv/bin/python /home/admin/projects/custom_browser/annoying_yt.py'
alias piprequirements='cat requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 pip install '
alias remote_one='nohup kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty > /dev/null 2>&1 & exit' 
alias set_bg='~/configs/hyprland/change_bg.sh'
alias link_source='~/bash_scripts/link_source.sh'

alias morning_music='~/projects/music_system/play_shell.sh'
alias music='conda activate music && python /home/admin/projects/music_system/music_system/second.py'

alias sigmoid='python ~/dlr/sonstig/sigmoid.py'
alias start_carla_server='CUDA_VISIBLE_DEVICES=1 DISPLAY=/home/admin/Carla-Simulator/carla15/CarlaUE4.sh'
alias act='/home/admin/projects/times/bash_times.sh'
alias bank='/home/admin/projects/goals/bash_calling.sh'
alias act_server='/home/admin/projects/act_server/start_client.sh'
alias act_test='/home/admin/projects/act_server/start_client.sh -t'
alias anki='QTWEBENGINE_CHROMIUM_FLAGS=“–no-sandbox” anki'
alias carla='/home/admin/Carla-Simulator/carla15/CarlaUE4.sh'
alias carlatsc='/home/admin/Carla-Simulator/v13_carla/CarlaUE4.sh'
# export VGL_ALLOWINDIRECT=1
# export VGL_FORCEALPHA=1
# export VGL_GLFLUSHTRIGGER=0
# export VGL_READBACK=pbo
# export VGL_SPOILLAST=0
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
# export XDG_SESSION_DESKTOP=Hyprland

export ANDROID_HOME=$HOME/Android/Sdk
export CUDA_HOME=/opt/cuda/bin


# export __GL_SYNC_TO_VBLANK=1
# export __GL_SYNC_DISPLAY_DEVICE=DFP-0
# export VDPAU_NVIDIA_SYNC_DISPLAY_DEVICE=DFP-0

# export GDK_SCALE=2
# export __NV_PRIME_RENDER_OFFLOAD=1

#export TF_ENABLE_ONEDNN_OPTS=1
#export TF_CPP_MIN_LOG_LEVEL=3
#export CUDA_FORCE_PTX_JIT=1
#export TF_FORCE_GPU_ALLOW_GROWTH=true

# !!! IF RUNNING ZOOM THIS MUST BE xcb
# export QT_QPA_PLATFORM=xcb
#
# export DRM_CAP_ATOMIC_ASYNC_PAGE_FLIP=1
#
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

export WLR_RENDERER_ALLOW_SOFTWARE=1
# export NCCL_DEBUG_FILE='/home/admin/hate_nvidia/log.out'

export PYDEVD_DISABLE_FILE_VALIDATION=1 
export PYTHONDONTWRITEBYTECODE=1


## The beautiful carla api
# export CARLA_ROOT=/home/admin/Carla-Simulator/v13_carla
# export SCENARIO_RUNNER_ROOT=/home/admin/Carla-Simulator/v13_carla/scenario_runner
# export PYTHONPATH=$PYTHONPATH:${CARLA_ROOT}/PythonAPI/carla
# export PYTHONPATH=$PYTHONPATH:${CARLA_ROOT}/PythonAPI/carla/dist/carla-0.9.13-py3.7-linux-x86_64.egg

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='==\W=> '

. "$HOME/.cargo/env"
# export FLUX_SCHNELL=~/.cache/huggingface/hub/models--black-forest-labs--FLUX.1-schnell/


if (command -v perl && command -v cpanm) >/dev/null 2>&1; then
  test -d "$HOME/perl5/lib/perl5" && eval $(perl -I "$HOME/perl5/lib/perl5" -Mlocal::lib)
fi

if [ "$(tty)" = "/dev/tty1" ] ; then
    #Your environment variables
    export QT_QPA_PLATFORM=wayland
    export MOZ_ENABLE_WAYLAND=1
    export MOZ_WEBRENDER=1
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=hyprland
    exec hyprland
fi

[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh
export _ZO_DATA_DIR=/home/admin/configs/zoxide/

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
   else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
__zoxide_oldpwd="$(__zoxide_pwd)"

function __zoxide_hook() {
    \builtin local -r retval="$?"
    \builtin local pwd_tmp
    pwd_tmp="$(__zoxide_pwd)"
    if [[ ${__zoxide_oldpwd} != "${pwd_tmp}" ]]; then
        __zoxide_oldpwd="${pwd_tmp}"
        \command zoxide add -- "${__zoxide_oldpwd}"
    fi
    return "${retval}"
}

# Initialize hook.
if [[ ${PROMPT_COMMAND:=} != *'__zoxide_hook'* ]]; then
    PROMPT_COMMAND="__zoxide_hook;${PROMPT_COMMAND#;}"
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

__zoxide_z_prefix='z#'

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ $# -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ $# -eq 1 && $1 == '-' ]]; then
        __zoxide_cd "${OLDPWD}"
    elif [[ $# -eq 1 && -d $1 ]]; then
        __zoxide_cd "$1"
    elif [[ $# -eq 2 && $1 == '--' ]]; then
        __zoxide_cd "$2"
    elif [[ ${@: -1} == "${__zoxide_z_prefix}"?* ]]; then
        # shellcheck disable=SC2124
        \builtin local result="${@: -1}"
        __zoxide_cd "${result:${#__zoxide_z_prefix}}"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" &&
            __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

\builtin unalias z &>/dev/null || \builtin true
function z() {
    __zoxide_z "$@"
}

\builtin unalias zi &>/dev/null || \builtin true
function zi() {
    __zoxide_zi "$@"
}

# Load completions.
# - Bash 4.4+ is required to use `@Q`.
# - Completions require line editing. Since Bash supports only two modes of
#   line editing (`vim` and `emacs`), we check if either them is enabled.
# - Completions don't work on `dumb` terminals.
if [[ ${BASH_VERSINFO[0]:-0} -eq 4 && ${BASH_VERSINFO[1]:-0} -ge 4 || ${BASH_VERSINFO[0]:-0} -ge 5 ]] &&
    [[ :"${SHELLOPTS}": =~ :(vi|emacs): && ${TERM} != 'dumb' ]]; then
    # Use `printf '\e[5n'` to redraw line after fzf closes.
    \builtin bind '"\e[0n": redraw-current-line' &>/dev/null

    function __zoxide_z_complete() {
        # Only show completions when the cursor is a
t the end of the line.
        [[ ${#COMP_WORDS[@]} -eq $((COMP_CWORD + 1)) ]] || return

        # If there is only one argument, use `cd` completions.
        if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
            \builtin mapfile -t COMPREPLY < <(
                \builtin compgen -A directory -- "${COMP_WORDS[-1]}" || \builtin true
            )
        # If there is a space after the last word, use interactive selection.
        elif [[ -z ${COMP_WORDS[-1]} ]] && [[ ${COMP_WORDS[-2]} != "${__zoxide_z_prefix}"?* ]]; then
            \builtin local result
            # shellcheck disable=SC2312
            result="$(\command zoxide query --exclude "$(__zoxide_pwd)" --interactive -- "${COMP_WORDS[@]:1:${#COMP_WORDS[@]}-2}")" &&
                COMPREPLY=("${__zoxide_z_prefix}${result}/")
            \builtin printf '\e[5n'
        fi
    }

    \builtin complete -F __zoxide_z_complete -o filenames -- z
    \builtin complete -r zi &>/dev/null || \builtin true
fi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.bashrc):
#
eval "$(zoxide init bash)"
