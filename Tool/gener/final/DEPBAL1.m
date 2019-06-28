DEPBAL1
	; 
	; ------ RUTINA JE AUTOMATICKY GENEROVANA SYSTEMEM SURICATA -----
	;            ------ JAKAKOLI ZMENA BUDE PREPSANA -----
	; 
	; Pro DEP.BAL -> ^ACN(CID,51) piece 1
	; podmiky: DEP.TYPE=SAV
	; dalsi data: N:DEP.ACN:99:1,N:DEP.ACCTNAME:1:5,
	; kanal: ZP312
	; 
	; ------ SEKCE PODMINKY -----
	; tady neco bude
	; 
	; ------ SESTAVENI ODCHOZI ZPRAVY ------
	; 
	S RES="DEP.BAL_:"_ACN_":"_"CID="_CID_":"_51_":"_1_":"_$ZTOLDval_":"_$ZTVALue
	; 
	; ------ SEKCE DALSI DATA -----
	I $D(^ACN(CID,99)) S XDAT=$P(^ACN(CID,99),"|",1)
	S RES=RES_"|DEP.ACN:"_ACN_":"_99_":"_1_":"_XDAT
	; 
	I $D(^ACN(CID,1)) S XDAT=$P(^ACN(CID,1),"|",5)
	S RES=RES_"|DEP.ACCTNAME:"_ACN_":"_1_":"_5_":"_XDAT
	; 
	; 
	; ###### tohle bude chtit vylepsit, zejmena odchytani chyb
	S P1="/tmp/ZP312"
	OPEN P1::"FIFO"
	USE P1
	W RES,!
	CLOSE P1
	; 
	Q 
