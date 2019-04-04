#!/bin/bash

RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

function echo_success() {
	$MOVE_TO_COL
	echo -n "["
	$SETCOLOR_SUCCESS
	echo -n $"  OK  "
	$SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 0
}

function echo_failure() {
	$MOVE_TO_COL
	echo -n "["
	$SETCOLOR_FAILURE
	echo -n $"FAILED"
	$SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 1
}

function echo_passed() {
	$MOVE_TO_COL
	echo -n "["
	$SETCOLOR_WARNING
	echo -n $"PASSED"
	$SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 1
}

function echo_warning() {
	$MOVE_TO_COL
	echo -n "["
	$SETCOLOR_WARNING
	echo -n $"WARNING"
	$SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 1
}

function abort_if_not_sourced() {
	if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
		$SETCOLOR_FAILURE
		echo -n "Script ${BASH_SOURCE[0]}" should be sourced.
		$SETCOLOR_NORMAL
		echo_failure
		echo
		exit 1
	fi
}

abort_if_not_sourced

function step() {
        # Check for `-a' argument to abort script if step is failed.
        STEP_ABORT_IF_FAILED=

	[[ $1 == -a ]] && { STEP_ABORT_IF_FAILED=1; shift; }
	[[ $1 == -- ]] && {                         shift; }

	STEP_OK=0
	STEP_DESC="$@"

	echo "$STEP_DESC"
	[[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
}

function try() {
	"$@"
	local EXIT_CODE=$?

	if [[ $EXIT_CODE -ne 0 ]]; then
		STEP_OK=$EXIT_CODE
		[[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
	fi
	return $EXIT_CODE
}

function next() {
	[[ -f /tmp/step.$$ ]] && { STEP_OK=$(< /tmp/step.$$); rm -f /tmp/step.$$; }
	if [[ $1 != -- ]]; then
		[[ $STEP_OK -eq 0 ]] && $SETCOLOR_SUCCESS || $SETCOLOR_FAILURE
		echo -n "$@"
		$SETCOLOR_NORMAL
	fi

	if [[ $STEP_OK -eq 0 ]]; then
		echo_success
		echo
	else
		echo_failure
		echo
	        [[ ! -z $STEP_ABORT_IF_FAILED ]] && exit $STEP_OK
	fi

	return $STEP_OK
}
