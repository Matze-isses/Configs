# ~/.bashrc
source ~/.bash_completion
if [ -f ~/.bash_completion ]; then
    . ~/.bash_completion
fi

alias drucken='~/configs/hyprland/skripts/drucken.sh'
alias scrape='conda activate serv && python -m webscraper collect'
alias ipv6='sudo sysctl net.ipv6.conf.all.disable_ipv6='

alias chrome='/home/admin/.conda/envs/serv/bin/python /home/admin/projects/custom_browser/annoying_yt.py'
alias piprequirements='cat requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 pip install'
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
alias carla='/home/admin/Carla-Simulator/v13_carla/CarlaUE4.sh'
# export VGL_ALLOWINDIRECT=1
# export VGL_FORCEALPHA=1
# export VGL_GLFLUSHTRIGGER=0
# export VGL_READBACK=pbo
# export VGL_SPOILLAST=0
# export XDG_CURRENT_DESKTOP=Hyprland
# export XDG_SESSION_TYPE=wayland
# export XDG_SESSION_DESKTOP=Hyprland

export ANDROID_HOME=$HOME/Android/Sdk

# !!! IF RUNNING ZOOM THIS MUST BE xcb
# export QT_QPA_PLATFORM=xcb

export CUDA_HOME=/opt/cuda/bin
# export __GL_SYNC_TO_VBLANK=1
# export __GL_SYNC_DISPLAY_DEVICE=DFP-0
# export VDPAU_NVIDIA_SYNC_DISPLAY_DEVICE=DFP-0

# GBM_BACKEND=nvidia-drm
# __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1

#export TF_ENABLE_ONEDNN_OPTS=1
#export TF_CPP_MIN_LOG_LEVEL=3
#export CUDA_FORCE_PTX_JIT=1
#export TF_FORCE_GPU_ALLOW_GROWTH=true

# export DRM_CAP_ATOMIC_ASYNC_PAGE_FLIP=1
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export QT_QPA_PLATFORM=wayland

# export WLR_RENDERER_ALLOW_SOFTWARE=1
# export NCCL_DEBUG_FILE='/home/admin/hate_nvidia/log.out'

export PYDEVD_DISABLE_FILE_VALIDATION=1 
export PYTHONDONTWRITEBYTECODE=1



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
export _ZO_DATA_DIR=./configs/zoxide/

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

