ZZGDB
	S ER=0
	S NODE=0
	S PIECE=0
	
	I $D(^DBTBL("SYSDEV",1,"EFTPAY",0)) S GLOB=^DBTBL("SYSDEV",1,"EFTPAY",0)
	E  S ER=1
	
	I $D(^DBTBL("SYSDEV",1,"EFTPAY",16)) S KEYS=^DBTBL("SYSDEV",1,"EFTPAY",16)
	E  S ER=1
	
	I $D(^DBTBL("SYSDEV",1,"EFTPAY",9,"RELREFNO"))  D
	. S NODE=$P(^DBTBL("SYSDEV",1,"EFTPAY",9,"RELREFNO"),"|",1)
	. S PIECE=$P(^DBTBL("SYSDEV",1,"EFTPAY",9,"RELREFNO"),"|",21)
	E  S ER=1
	
	I ER=0 S RES="ZZRES="_GLOB_"#"_KEYS_"#"_NODE_"#"_PIECE W RES,!
	E  W "ZZRES=1",!
	
	Q
