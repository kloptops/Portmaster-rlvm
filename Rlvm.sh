#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls

GAMEDIR="/$directory/ports/rlvm"
cd $GAMEDIR

# Set this to the game you want to play
GAME="GAMENAME"

if [[ !-d "${GAMEDIR}/games/${GAME}" ]]; then
  echo "No game files found." > ./log.txt
  $ESUDO systemctl restart oga_events &
  exit 1
fi

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0


$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export LIBGL_NOERROR=0

export SDL12COMPAT_USE_GAME_CONTROLLERS=1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH:/usr/lib32"

$GPTOKEYB "rlvm" -c "${GAMEDIR}/rlvm.gptk" &
$TASKSET ./rlvm --font "${GAMEDIR}/msgothic.ttc" "${GAMEDIR}/games/${GAME}/" 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> /dev/tty0
