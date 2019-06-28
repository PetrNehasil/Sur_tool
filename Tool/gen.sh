#!/usr/bin/env ksh93
#

#WOR_KSH_OPTS="-x"	# set for debugging

error_exit() {
	log "=== ERROR === ${1}"
	exit 1
}

export WOR_HOME=$(cd $(dirname ${0}); echo ${PWD})
export WOR_LIB=${WOR_HOME}/lib
export WOR_PHASES=${WOR_HOME}/phase
export WOR_GEN=${WOR_HOME}/gener

if [ "x" == "x${FPATH}" ] ; then
	export FPATH=${WOR_LIB}
else
	export FPATH="${FPATH}:${WOR_LIB}"
fi

export PATH="${PATH}:${WOR_LIB}"
if [ "$(uname)" = "Linux" ] 
then
	export KSH93="$(which ksh93) ${WOR_KSH_OPTS}"
else
	export KSH93="$(whence ksh93) ${WOR_KSH_OPTS}"
fi

params=${@}
load_params "${@}"

[ ${last_step} -lt ${first_step} ] && error_exit "First step (${first_step}) must be less or equal to last step (${last_step})." 

export WOR_PHASE_DIR=${WOR_PHASES}/${phase}
[ -d ${WOR_PHASE_DIR} ] || error_exit "Phase ${phase} directory not found in ${WOR_PHASES}"

[[ -e ${SRCENV} ]] || error_exit "Source environment ${SRCENV} not found."
[[ -e ${TGTENV} ]] || error_exit "Target environment ${TGTENV} not found."

WOR_LOGDIR=${WOR_HOME}/log
[ -d ${WOR_LOGDIR} ] || mkdir ${WOR_LOGDIR} || error_exit "Error creating log directory ${WOR_LOGDIR}" $?
#export WOR_LOG=${WOR_LOGDIR}/mig_$(echo ${TGTENV} | tr -d '/')_${WOR_PHASES}_$(date +%y%m%d%H%M%S).log
export WOR_LOG=${WOR_LOGDIR}/${phase}_$(date +%y%m%d-%H%M%S).log

log
log "${0} ${@}"
log
log "----- settings -----"
log "Working home: ${WOR_HOME}"
log "Source      : ${SRCENV}"
log "Target      : ${TGTENV}"
log "Phase       : ${phase}"
log "Phase dir   : ${WOR_PHASE_DIR}"


[ ${first_step:-0} -gt 0 ] && log "First step    : ${first_step}"
[ ${last_step:-999} -lt 999 ] && log "Last step     : ${last_step}"
log "--------------------"

typeset -ZR3 step_number
typeset -i last_step_done

for (( step=${first_step:-0}; step<=${last_step:-999} ; step++ )); do
 	## not working on AIX # for step_number in {${first_step:-0}..${last_step:-999}}; do
	step_number=$step	#formatted number

	# check the country specific step first

	files=(${WOR_PHASE_DIR}/${step_number}_*)
	step_file=${files[0]}
	#step_file=$(find ${WOR_PHASE_DIR}/ -name "${step_number}*" | head -n 1 | grep -m 1 "${step_number}")

	if [ -r ${step_file} ] ; then
		log "Executing step ${step_number} - $(basename ${step_file})"
		log "${KSH93} ${step_file} ${@}"
		${KSH93} ${step_file} "${@}"
		status=$?
		[ ${status} -ne 0 ] && error_exit "Step $(basename ${step_file}) failed with status ${status}"
		last_step_done=${step_number}
		continue
	fi

	# country specifi step not found, try the common one
	files=(${WOR_PHASE_DIR}/${step_number}_*)
	step_file=${files[0]}

	if [ -r ${step_file} ] ; then
		log "Executing step ${step_number} - $(basename ${step_file})"
		log "${KSH93} ${step_file} ${@}"
		${KSH93} ${step_file} "${@}"
		status=$?
		[ ${status} -ne 0 ] && error_exit "Step $(basename ${step_file}) failed with status ${status}"
		last_step_done=${step_number}
		continue
	fi

done

log "Phase ${phase} finished with step ${last_step_done}."
