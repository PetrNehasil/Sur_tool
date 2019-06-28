#!/usr/bin/env ksh93
#

load_params "$@"

log "Gen scripts"
 
[ -e ${SRCENV} ] || error_exit "No config found"
[ -e ${PIPDIR} ] || error_exit "DIR for pipes not found "

OUT_DIR="${WOR_GEN}/final"
FIN_SCR="${OUT_DIR}/make_pipe.sh"

echo "#!/usr/bin/env ksh93" >> ${FIN_SCR}
echo "#" >> ${FIN_SCR}
echo "#" >> ${FIN_SCR}

while read line
   do
    #echo "$line"
    pline=`echo $line | sed '/^;/d' | tr [a-z] [A-Z]`

    if [ "$pline" != "" ]
     then
      chan=`echo $pline | cut -d"#" -f4`
      [ "$chan" ] || error_exit "Channel missing"

      echo "mkfifo \"${PIPDIR}/$chan\"" >> ${FIN_SCR}

    fi




  done < ${SRCENV}
