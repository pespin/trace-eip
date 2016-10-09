#!/bin/sh

PID=$1
if [ -z "$PID" ] || ! [ -e /proc/$PID ]; then
  echo "you must provide a valid PID!"
  exit 1
fi

######## CONFIG #####
SLEEP_PERIOD="0.1"
TDIR="dump.$PID"
#####################

do_continue=true

trap "" INT
function trace_task_stop() {
        echo "INT received, stopping"
        do_continue=false
}

# $1: pid, $2: tid
get_pc() {
  local PID=$1
  local TID=$2
  local PC=$( cat /proc/$PID/task/$TID/stat | awk '{ print $30 }' | xargs printf '%x' )
  echo $PC
}

trace_task() {
  trap trace_task_stop INT
  local TID=$1
  local TDIR=$2
  local TNAME="$( cat /proc/$PID/task/$TID/comm | tr A-Z a-z | sed -r 's/[^a-zA-Z0-9\-]+/_/g' )"
  local TFILE="$TDIR/task-$PID-$TID-$TNAME"
  echo "[$BASHPID] Start tracing task $TID ($TNAME)"
  echo -n "" >"$TFILE"
  while $do_continue; do
    local PC="$( get_pc $PID $TID )"
    echo $PC >>"$TFILE"
    echo $PC
    sleep $SLEEP_PERIOD
  done
  echo "[$BASHPID] Stop tracing task $TID"
}

save_maps() {
  local PID=$1
  local TDIR=$2
  cat /proc/$PID/maps >"$TDIR/maps"
}

rm -rf "$TDIR"
mkdir -p "$TDIR"

save_maps $PID "$TDIR"
for tk in $(ls /proc/$PID/task/); do
  trace_task $tk $TDIR &
done

echo "[$BASHPID] waiting for CTRL+C"
wait
echo "[$BASHPID] Finished wait $?"
