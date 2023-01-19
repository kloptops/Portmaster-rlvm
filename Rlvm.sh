#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

GAMEDIR="/$directory/ports/rlvm"
cd $GAMEDIR

width=55
height=15

$ESUDO chmod 666 $CUR_TTY
export TERM=linux
printf "\033c" > $CUR_TTY

if [ -z ${GAME+x} ]; then

  printf "\e[?25h" > $CUR_TTY
  dialog --clear


  $GPTOKEYB "dialog" -c "${GAMEDIR}/rlvm-menu.gptk" &

  GAMEEXES=( $(find games/ -maxdepth 2 -iname 'gameexe.ini') );
  if [ "${#GAMEEXES[@]}" -eq 0 ]; then
    dialog \
    --backtitle "Real Life VM" \
    --title "[ Error ]" \
    --clear \
    --msgbox "No Games Found!" $height $width > $CUR_TTY

    $ESUDO kill -9 $(pidof gptokeyb)
    $ESUDO systemctl restart oga_events &
    exit 1;
  fi

  VN_CHOICES=()
  VN_DIRS=()
  for i in "${!GAMEEXES[@]}"; {
    VN_PATH=$(dirname "${GAMEEXES[$i]}")
    VN_DIR=${VN_PATH##*/}
    VN_NAME="${VN_DIR}"
    ## This breaks dialog :(
    # VN_NAME=$(iconv -f CP932 -t UTF-8 "${GAMEEXES[$i]}"; |  grep -G '#CAPTION=' | cut -d '"' -f 2)
    echo "$i -> ${VN_DIR} -> ${VN_NAME}" 2>&1 | tee -a ./log.txt
    VN_CHOICES+=($i "${VN_NAME}")
    VN_DIRS+=("${VN_DIR}")
  }


  GAME_SELECT=(dialog \
    --backtitle "Real Life VM" \
    --title "[ Select Game ]" \
    --clear \
    --menu "Choose Your Game" $height $width 15)

  VN_CHOICE=$("${GAME_SELECT[@]}" "${VN_CHOICES[@]}" 2>&1 > $CUR_TTY)
  if [ $? != 0 ]; then
    $ESUDO kill -9 $(pidof gptokeyb)
    $ESUDO systemctl restart oga_events &
    echo "QUIT: ${VN_CHOICE}" 2>&1 | tee -a ./log.txt
    exit 1;
  fi

  echo "${VN_OPT} -> ${VN_CHOICE} -> ${VN_DIRS[$VN_CHOICE]}" 2>&1 | tee -a ./log.txt

  $ESUDO kill -9 $(pidof gptokeyb)

  GAME="${VN_DIRS[$VN_CHOICE]}"
fi

printf "\033c" > $CUR_TTY
## RUN SCRIPT HERE

if [[ -f "$GAMEDIR/fonts/msgothic.ttc" ]]; then
  MSGOTHIC="--font $GAMEDIR/fonts/msgothic.ttc"
fi

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export LIBGL_NOERROR=0

export SDL12COMPAT_USE_GAME_CONTROLLERS=1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH:/usr/lib32"

$GPTOKEYB "rlvm" -c "${GAMEDIR}/rlvm.gptk" &
$TASKSET ./rlvm $MSGOTHIC "${GAMEDIR}/games/${GAME}/" 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
