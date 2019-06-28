CIFXNAM1
	; 
	; ------ RUTINA JE AUTOMATICKY GENEROVANA SYSTEMEM SURICATA -----
	;            ------ JAKAKOLI ZMENA BUDE PREPSANA -----
	; 
	; Pro CIF.NAM -> ^CIF(ACN,1) piece 1
	; podmiky: 
	; dalsi data: N:CIF.XNAME:1:2,
	; kanal: ZP313
	; 
	; ------ SEKCE PODMINKY -----
	; Podminky nejsou
	; 
	; ------ SESTAVENI ODCHOZI ZPRAVY ------
	; 
	S RES="CIF.NAM_:"_CIF_":"_"ACN="_ACN_":"_1_":"_1_":"_$ZTOLDval_":"_$ZTVALue
	; 
	; ------ SEKCE DALSI DATA -----
	I $D(^CIF(ACN,1)) S XDAT=$P(^CIF(ACN,1),"|",2)
	S RES=RES_"|CIF.XNAME:"_CIF_":"_1_":"_2_":"_XDAT
	; 
	; 
	; ###### tohle bude chtit vylepsit, zejmena odchytani chyb
	S P1="/tmp/ZP313"
	OPEN P1::"FIFO"
	USE P1
	W RES,!
	CLOSE P1
	; 
	Q 
