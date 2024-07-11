#
# ~/.bashrc
#
#
export PYTHONDONTWRITEBYTECODE=1
# export PATH=/opt/cuda/bin:$PATH
# export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
export PATH="/home/admin/bin:$PATH"

export UE4_ROOT=~/UnrealEngine
export CARLA_ROOT=~/Carla-Simulator/carla13/
export SCENARIO_RUNNER_ROOT=~/Carla-Simulator/carla13/scenario_runner/
export PYTHONPATH=$PYTHONPATH:${CARLA_ROOT}/PythonAPI/carla/dist/carla-0.9.13.egg

export "GTK_USE_PORTAL=1"
export "CRYPTOGRAPHY_OPENSSL_NO_LEGACY"=1


alias piprequirements='cat requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 pip install'
alias remote='nohup kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty > /dev/null 2>&1 & exit' 
alias set_bg='~/configs/hyprland/change_bg.sh'
alias link_source='~/bash_scripts/link_source.sh'

alias morning_music='~/projects/music_system/play_shell.sh'
alias music='~/projects/music_system/play_music.sh'

alias sigmoid='python ~/projects/debug/math/math_plots/sigmoid_plot.py'
alias carla='/home/admin/Carla-Simulator/carla15/CarlaUE4.sh'
alias act='/home/admin/projects/times/bash_times.sh'
alias bank='/home/admin/projects/goals/bash_calling.sh'
alias act_server='/home/admin/projects/act_server/start_client.sh'
alias act_test='/home/admin/projects/act_server/start_client.sh -t'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


. "$HOME/.cargo/env"
eval "$(zoxide init bash)"


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

[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
