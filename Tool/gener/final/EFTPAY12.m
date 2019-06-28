EFTPAY12
	; 
	; ------ RUTINA JE AUTOMATICKY GENEROVANA SYSTEMEM SURICATA -----
	;            ------ JAKAKOLI ZMENA BUDE PREPSANA -----
	; 
	; Pro EFTPAY.RELREFNO -> ^EFTPAY(CID,SEQ,0) piece 3
	; podmiky: EFTPAY.SEQ>30
	; dalsi data: 
	; kanal: ZP314
	; 
	; ------ SEKCE PODMINKY -----
	; tady neco bude
	; 
	; ------ SESTAVENI ODCHOZI ZPRAVY ------
	; 
	S RES="EFTPAY.RELREFNO_:"_EFTPAY_":"_,"CID="_CID_,"SEQ="_SEQ_":"_0_":"_3_":"_$ZTOLDval_":"_$ZTVALue
	; 
	; ------ SEKCE DALSI DATA -----
	; dalsi data nikdo nechce
	; 
	; ###### tohle bude chtit vylepsit, zejmena odchytani chyb
	S P1="/tmp/ZP314"
	OPEN P1::"FIFO"
	USE P1
	W RES,!
	CLOSE P1
	; 
	Q 
