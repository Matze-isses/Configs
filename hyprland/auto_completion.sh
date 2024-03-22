
_myscript_completions()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -W "gray blue_red" -- "$cur"))
}

complete -F _myscript_completions change_bg
