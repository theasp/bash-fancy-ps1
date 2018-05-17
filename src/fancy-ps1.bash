#!/bin/bash

function __fancy_ps1__init {
  if [[ $__FANCY_PS1__INIT != true ]]; then
    FANCYPS1_CWDLENGTH=30
    FANCYPS1=${PS1:-"\h:\w\$ "}

    case $(locale charmap) in
      # 2736 = ✷  279d = ➝  2026 = …
      UTF-8) FANCYPS1_FILL=$'\u2736' ;;
      *)     FANCYPS1_FILL="..." ;;
    esac

    precmd_functions+=(__fancy_ps1__ps1_precmd)

    case $TERM in
      screen*|xterm*|tmux*)
        precmd_functions+=(__fancy_ps1__xterm_precmd)
        preexec_functions+=(__fancy_ps1__xterm_preexec)
        ;;
    esac

    __FANCY_PS1__INIT=true
  fi
}

function __fancy_ps1__xterm_precmd {
  echo -ne "\033]2;${USER}@${HOSTNAME}:${FANCYPS1_CWD}\007"
}

function __fancy_ps1__xterm_preexec {
  read cmd <<<"$1"
  echo -ne "\033]2;${USER}@${HOSTNAME}:${FANCYPS1_CWD} ${cmd##*/}\007"
}

function __fancy_ps1__cwd {
  FANCYPS1_CWDLENGTH=${FANCYPS1_CWDLENGTH:=30}
  FANCYPS1_FILL=${FANCYPS1_FILL:=...}
  FANCYPS1_DYNAMIC=${FANCYPS1_DYNAMIC:=0}

  if [ "$FANCYPS1_DYNAMIC" != 0 ]; then
    FANCYPS1_CWDLENGTH=$(( $COLUMNS * $FANCYPS1_DYNAMIC / 100 ))
  fi

  HOMEDIR="${HOME%/}/"
  DIR="${PWD}/"
  DIR=${DIR/#$HOMEDIR/\~/}
  DIR=${DIR%/}

  if [ "${#DIR}" -gt $FANCYPS1_CWDLENGTH ]; then
    WORK=${DIR}
    COUNT=0
    while [ "${#WORK}" -gt 0 ]; do
      element="${WORK/%\/*//}"
      len=${#element}
      WORK=${WORK:$len}

      if [ "$element" != "" ]; then
        COUNT=$(($COUNT + 1))
        DIRS[$COUNT]=$element
      fi
    done

    if [ $COUNT -gt 3 ]; then
      START=${DIRS[1]}
      END=${DIRS[$COUNT]}

      DIR="${START}${FANCYPS1_FILL}/${END}"

      i=1

      while [ "${#DIR}" -le $FANCYPS1_CWDLENGTH ]; do
        i=$(($i + 1))

        START="${START}${DIRS[$i]}"
        TMP="${START}${FANCYPS1_FILL}/${END}"
        if [ "${#TMP}" -gt $FANCYPS1_CWDLENGTH ]; then
          break
        fi
        DIR=$TMP

        END=${DIRS[$(($COUNT - $i + 1))]}${END}
        TMP="${START}${FANCYPS1_FILL}/${END}"
        if [ "${#TMP}" -gt $FANCYPS1_CWDLENGTH ]; then
          break
        fi
        DIR=$TMP
      done
    fi
  fi

  echo $DIR
}

function __fancy_ps1__prompt {
  FANCYPS1_PROMPT_CMD=${FANCYPS1_PROMPT_CMD:="test $UID = 0"}
  FANCYPS1_PROMPT_CMD_TRUE=${FANCYPS1_PROMPT_CMD_TRUE:-"#"}
  FANCYPS1_PROMPT_CMD_FALSE=${FANCYPS1_PROMPT_CMD_FALSE:-"$"}

  if $FANCYPS1_PROMPT_CMD > /dev/null 2>&1; then
    echo -ne $FANCYPS1_PROMPT_CMD_TRUE
  else
    echo -ne $FANCYPS1_PROMPT_CMD_FALSE
  fi
}

function __fancy_ps1__ps1_precmd {
  FANCYPS1_CWD=$(__fancy_ps1__cwd)
  FANCYPS1_PROMPT=$(__fancy_ps1__prompt)

  PS1="$FANCYPS1"
  PS1=${PS1//\\\$/${FANCYPS1_PROMPT}}
  PS1=${PS1//\\w/${FANCYPS1_CWD}}
}

__fancy_ps1__init
