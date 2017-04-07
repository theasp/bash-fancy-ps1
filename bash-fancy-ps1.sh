#!/bin/bash

case $(locale charmap) in
  UTF-8)
    FANCYPS1_FILL="$(echo -ne '\u2736')" # 2736 = ✷  279d = ➝  2026 = …
    ;;

  *)
    FANCYPS1_FILL="..."
    ;;
esac

FANCYPS1_CWDLENGTH=30

function _fancyps1_cwd {
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

function _fancyps1_prompt {
  FANCYPS1_PROMPT_CMD=${FANCYPS1_PROMPT_CMD:="sudo -ln true"}
  FANCYPS1_PROMPT_CMD_TRUE=${FANCYPS1_PROMPT_CMD_TRUE:-"#"}
  FANCYPS1_PROMPT_CMD_FALSE=${FANCYPS1_PROMPT_CMD_FALSE:-"$"}

  if $FANCYPS1_PROMPT_CMD > /dev/null 2>&1; then
    echo -ne $FANCYPS1_PROMPT_CMD_TRUE
  else
    echo -ne $FANCYPS1_PROMPT_CMD_FALSE
  fi
}

function _fancyps1 {
  FANCYPS1_CWD=$(_fancyps1_cwd)
  FANCYPS1_PROMPT=$(_fancyps1_prompt)

  PS1="$FANCYPS1"
  PS1=${PS1//\\\$/${FANCYPS1_PROMPT}}
  PS1=${PS1//\\w/${FANCYPS1_CWD}}
}

FANCYPS1=${PS1:-"\h:\w\$ "}
PROMPT_COMMAND='_fancyps1'

case $TERM in
  screen*|xterm*|tmux*)
    PROMPT_COMMAND=${PROMPT_COMMAND}';echo -ne "\033]2;${USER}@${HOSTNAME}:${FANCYPS1_CWD}\007"'
    ;;
esac
