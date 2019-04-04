#!/bin/bash

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

function check_src_dir() {
	if [ ! -d "$(pwd)/$KERNEL_SRC" ]; then
		$SETCOLOR_FAILURE
		echo "Incorrect kernel src directory:"
		echo "$(pwd)/$KERNEL_SRC"
		$SETCOLOR_NORMAL
		return 1
	fi
	return 0
}

function check_dt_dir() {
	if [ ! -d "$(pwd)/$DT_OUT" ]; then
		$SETCOLOR_FAILURE
		echo "Incorrect dtb out directory:"
		echo "$(pwd)/$KERNEL_DT_OUT"
		$SETCOLOR_NORMAL
		return 1
	fi
	return 0
}


function check_android_env() {
	if [ ! -d "$ANDROID_BUILD_TOP" ]; then
		$SETCOLOR_FAILURE
		echo "Android build environment is not set."
		$SETCOLOR_NORMAL
		return 1
	fi
	return 0
}
