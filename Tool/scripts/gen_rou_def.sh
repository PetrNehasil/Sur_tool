#!/usr/bin/env ksh93
#

load_params "$@"

log "Gen routines definition"

TMP_TRG="${WOR_GEN}/trig_tmp"
ROU_DEF1="${TMP_TRG}/ROU_DEF1"

OUT_DIR="${WOR_GEN}/final"

#+^CIF(acn=:,1) -delim="|" -pieces=2 -commands=SET,KILL -xecute="Do ^XNAMEinCIF"
 
[ -e ${ROU_DEF1} ] || error_exit "Routine def not found"

# ITEM#GLOBAL#KLICE#NODE#PIECE#PODMINKY#DALSI POLE#KANAL#JMENO_OBSLUZNE_RUTINY
# DEP.BAL#ACN#CID#51#1##N:DEP.ACN:99:1:C:DEP.BALAVL:$$BALAVL^DEPCDI(CID,BALAVLCODE):N:DEP.ACCTNAME:1:5:#ZP312#DEPBAL1
while read line
   do
     #echo "$line" 
    
     item=`echo $line | cut -d"#" -f1`
     glob=`echo $line | cut -d"#" -f2`
     keys=`echo $line | cut -d"#" -f3`
     node=`echo $line | cut -d"#" -f4`
     piece=`echo $line | cut -d"#" -f5`

     cond=`echo $line | cut -d"#" -f6`

     other=`echo $line | cut -d"#" -f7`
     chan=`echo $line | cut -d"#" -f8`
     rnam=`echo $line | cut -d"#" -f9`

# pro jistotu pridat kontroly na prazdna pole


     OUT_FIL="${OUT_DIR}/$rnam.m"
     echo "$rnam" >> ${OUT_FIL}
     echo "	; "  >> ${OUT_FIL}
     echo "	; ------ RUTINA JE AUTOMATICKY GENEROVANA SYSTEMEM SURICATA -----" >> ${OUT_FIL}
     echo "	;            ------ JAKAKOLI ZMENA BUDE PREPSANA -----" >> ${OUT_FIL}
     echo "	; "  >> ${OUT_FIL}
     echo "	; Pro $item -> ^$glob($keys,$node) piece $piece" >> ${OUT_FIL} 
     echo "	; podmiky: $cond" >> ${OUT_FIL} 
     echo "	; dalsi data: $other" >> ${OUT_FIL} 
     echo "	; kanal: $chan" >> ${OUT_FIL} 
     echo "	; "  >> ${OUT_FIL}

# nejdriv podminky, neb kdyz nebudou splneny, nic neposilame a muzeme to zabalit
     
     echo "	; ------ SEKCE PODMINKY -----" >> ${OUT_FIL}

     if [ "$cond" ] 
      then 
       echo "	; tady neco bude" >> ${OUT_FIL}
      else
       echo "	; Podminky nejsou" >> ${OUT_FIL}
     fi
  
     echo "	; "  >> ${OUT_FIL}
     echo "	; ------ SESTAVENI ODCHOZI ZPRAVY ------" >> ${OUT_FIL}
     echo "	; "  >> ${OUT_FIL}

# item:global:key1=val1,key2=val2...:node:piece:stara:nova|dalsi1|dalsi2|....
# kde dalsix jest N:item:global:node:piece:hodnota je li obycejne dato
# C:item:hodnota pro pocitatelne dato

# zmenena hodnota "item"
     kkeys=`up_keys $keys`
     pod="_"

     echo "	S RES=\"$item$pod:\"$pod$glob$pod\":\"$pod$kkeys\":\"$pod$node$pod\":\"$pod$piece$pod\":\"$pod\$ZTOLDval$pod\":\"$pod\$ZTVALue" >> ${OUT_FIL}
     echo "	; " >> ${OUT_FIL}

# pridame dalsi data, jsou-li pozadovana
  
     echo "	; ------ SEKCE DALSI DATA -----" >> ${OUT_FIL}
     if [ "$other" ] 
      then 
       #echo "	; tady neco bude" >> ${OUT_FIL}

# N:...obycejna polozka, C:...pocitana data ve stejnem globale
# D:...polozka v jinem globale a k tomu navod jak ji najit
# pro N a C je uz v DBTBL overeno, ziskan node i piece

       for otem in `echo $other | sed s'/,/ /'g`
        do
          roz=` echo $otem | cut -d":" -f1`
          xite=` echo $otem | cut -d":" -f2`
          xnod=` echo $otem | cut -d":" -f3`
          xpic=` echo $otem | cut -d":" -f4`

          XPOM="XDAT"
          case $roz in
            N) echo "	I \$D(^$glob($keys,$xnod)) S XDAT=\$P(^$glob($keys,$xnod),\"|\",$xpic)" >> ${OUT_FIL}
               echo "	S RES=RES_\"|$xite:\"$pod$glob$pod\":\"$pod$xnod$pod\":\"$pod$xpic$pod\":\"$pod$XPOM" >> ${OUT_FIL}
               echo "	; " >> ${OUT_FIL}
               ;;
            C) echo "je to C"
               ;;
            D) echo "je to D"
               ;;
            *) error_exit "Divna dalsi data, ze by chyba v programu?"
               ;;
          esac


        done
       
      else
       echo "	; dalsi data nikdo nechce" >> ${OUT_FIL}
     fi

     echo "	; " >> ${OUT_FIL}
     echo "	; ###### tohle bude chtit vylepsit, zejmena odchytani chyb" >> ${OUT_FIL}
     echo "	S P1=\"/tmp/$chan\"" >> ${OUT_FIL}
     echo "	OPEN P1::\"FIFO\"" >> ${OUT_FIL}
     echo "	USE P1" >> ${OUT_FIL}
     echo "	W RES,!" >> ${OUT_FIL}
     echo "	CLOSE P1" >> ${OUT_FIL}
     echo "	; " >> ${OUT_FIL}
    
     echo "	Q " >> ${OUT_FIL}
  done < ${ROU_DEF1}


