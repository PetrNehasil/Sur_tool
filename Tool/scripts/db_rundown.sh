#!/usr/bin/env ksh93
#

load_params "$@"

log "Running rundown in ${TGTENV}"

[ -d ${TGTENV} ] || error_exit "No target directory found"

. ${TGTENV}/biowenv #> /dev/null

	CMD="mupip rundown -r \"*\""
	log "$CMD;started"
	${CMD} || error_exit "Error status $?"

	exit 0
