#!/usr/bin/env ksh93
#

load_params "$@"

log "Gen triggers definition"

TMP_TRG="${WOR_GEN}/trig_tmp"
TRG_DEF1="${TMP_TRG}/TRG_DEF1"

OUT_DIR="${WOR_GEN}/final"
mkdir ${OUT_DIR}
FIN_TRG="${OUT_DIR}/trigers.trg"

#+^CIF(acn=:,1) -delim="|" -pieces=2 -commands=SET,KILL -xecute="Do ^XNAMEinCIF"
 
[ -e ${TRG_DEF1} ] || error_exit "TRG def not found"

# GLOBAL#KLICE#NODE#PIECE#S|K#JMENO_OBSLUZNE_RUTINY
while read line
   do
     #echo "$line" 
    
     item=`echo $line | cut -d"#" -f1`
     glob=`echo $line | cut -d"#" -f2`
     keys=`echo $line | cut -d"#" -f3`
     node=`echo $line | cut -d"#" -f4`
     piece=`echo $line | cut -d"#" -f5`
     ttyp=`echo $line | cut -d"#" -f6`
     rnam=`echo $line | cut -d"#" -f7`

     rm -f /tmp/$$_trgtmp
     echo "+^$glob(\\" >> /tmp/$$_trgtmp

     for okey in `echo $keys | sed s'/,/ /'g`
      do
        echo "$okey=:,\\" >> /tmp/$$_trgtmp
      done
     
     echo "$node) -delim=\"|\" -pieces=$piece -commands=$ttyp -xecute=\"DO ^$rnam\"" >> /tmp/$$_trgtmp

     cat /tmp/$$_trgtmp | sed -e :a -e '/\\$/N; s/\\\n//; ta' >> ${FIN_TRG}

     rm -f /tmp/$$_trgtmp

    
  done < ${TRG_DEF1}

