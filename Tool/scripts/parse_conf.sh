#!/usr/bin/env ksh93
#

load_params "$@"

log "Check config file ${SRCENV}"

[ -e ${SRCENV} ] || error_exit "No config found"

[ -e ${TGTENV}/gtmenv ] || error_exit "${TGTENV}/gtmenv not found"

TMP_DBTBL="${WOR_GEN}/dbtbl_tmp"
mkdir ${TMP_DBTBL}

TMP_NAM="${TMP_DBTBL}/ZZGDB.m"
TMP_ERR="${TMP_DBTBL}/err"

TMP_TRG="${WOR_GEN}/trig_tmp"
mkdir ${TMP_TRG}
TRG_DEF1="${TMP_TRG}/TRG_DEF1"
ROU_DEF1="${TMP_TRG}/ROU_DEF1"

while read line
   do
    #echo "$line" 
    pline=`echo $line | sed '/^;/d' | tr [a-z] [A-Z]`
    
    if [ "$pline" != "" ]
     then

       item=`echo $pline | cut -d"#" -f1`
       cond=`echo $pline | cut -d"#" -f2`
       other=`echo $pline | cut -d"#" -f3`
       chan=`echo $pline | cut -d"#" -f4`
       tnam=`echo $pline | cut -d"#" -f5`
       ttyp=`echo $pline | cut -d"#" -f6`

       [ "$item" ] || error_exit "Item missing"
       [ "$chan" ] || error_exit "Channel missing"
       [ "$tnam" ] || error_exit "Trigger name missing"
       [ "$ttyp" ] || error_exit "Trigger type missing"

# pripadne dalsi kontroly na jednotliva pole

# z DBTBL zjistime v jakem globalu je nas "item", jake jsou klice a na kterem node a piece sedi
# to staci pro vygenerovani definice triggeru, vrati se GLOBAL#KLICE#NODE#PIECE, napr: 
# pro DEP.CID -> ACN#CID#51#1, nebo CIF.NAM -> CIF#ACN#1#1, neni-li "item" i DBTBL vrati se 1

       ch_dbtbl_fil $item ${TMP_NAM} ${TMP_ERR}
       res=`grep "ZZRES" $tmp_err | cut -d"=" -f2`

       #echo ">>$res<<"
       echo $res | grep "#" > /dev/null
       [ $? -eq 0 ] || error_exit "$item not found in DBTBL" 
# tady jeste mozna dalsi rozliseni dle ev. chyboveho kodu...

       glob=`echo $res | cut -d"#" -f1`
       keys=`echo $res | cut -d"#" -f2`
       node=`echo $res | cut -d"#" -f3`
       piece=`echo $res | cut -d"#" -f4`
# a tady jeste kontroly na smysluplnost glob keys?

       [ "$node" ] || error_exit "$item is probably computed"
       [ "$piece" ] || error_exit "$item is probably computed"

# do ${TMP_TRG} vygenerujeme data pro sestaveni definice trigeru
# kazdy triger bude mit svuj radek v TRG_DEF1 s obsahem
# ITEM#GLOBAL#KLICE#NODE#PIECE#S|K#JMENO_OBSLUZNE_RUTINY

       echo "$item#$glob#$keys#$node#$piece#$ttyp#$tnam" >> "${TRG_DEF1}"



# do ${TMP_TRG} vygenerujeme data pro sestaveni rutiny, kterou trigger vola
# kazda rutina ma jeden radek v souboru ${ROU_DEF1} s obsahem
# ITEM#GLOBAL#KLICE#NODE#PIECE#PODMINKY#DALSI POLE#KANAL#JMENO_OBSLUZNE_RUTINY

       echo "$item#$glob#$keys#$node#$piece#\\" >> "${ROU_DEF1}"

## zjistime, jestli se vsechna data z podminky daji najit

       echo "$cond#\\" >> "${ROU_DEF1}"

# opet probereme DBTBL, abychom zjistili kde se nachazi dalsi data, ktera
# mame poslat


       if [ "$other" ] 
        then
          #echo "Mame $other"
          for tot in `echo $other | sed s'/,/ /'g`
            do
              #echo $tot
              echo $tot | grep ":" > /dev/null
	      if [ $? -eq 0 ]
               then
                echo "slozite"
                echo $tot # v souboru pak bude D:.... jako hrozne tezke to vyjadrit
               else
                echo "jednoduche"
                ptot=`echo $tot | cut -d"." -f1`
                pitem=`echo $item | cut -d"." -f1`
                [ "$pitem" == "$ptot" ] || error_exit "$item X $tot different filedef?"
                ch_dbtbl_otj $tot ${TMP_NAM} ${TMP_ERR}
                res=`grep "ZZRES" $tmp_err | cut -d"=" -f2`

                #echo ">>$res<<"
                echo $res | grep "#" > /dev/null
                [ $? -eq 0 ] || error_exit "$item not found in DBTBL" 

                count=`echo $res | cut -d"#" -f1`
                #echo $count
                if [ _"$count" != _"" ]
                 then
                  echo "C:$tot:$count,\\" >> "${ROU_DEF1}"
                 else
                  echo "normalni polozka"
                  echo $res
                  node=`echo $res | cut -d"#" -f2`
                  piece=`echo $res | cut -d"#" -f3`
                  
                  echo $node | grep "*" > /dev/null
                  [ $? -ne 0 ] || error_exit "$tot is KEY, check your conf file" 

                  echo "N:$tot:$node:$piece,\\" >> "${ROU_DEF1}"

                fi
              fi
            done
       fi 

# nakonec kanal a jmeno rutiny

       echo "#$chan#$tnam" >> "${ROU_DEF1}"


    fi
    cat ${ROU_DEF1} | sed -e :a -e '/\\$/N; s/\\\n//; ta' > /tmp/$$_rou_tmp
    mv /tmp/$$_rou_tmp ${ROU_DEF1}
    
  done < ${SRCENV}

