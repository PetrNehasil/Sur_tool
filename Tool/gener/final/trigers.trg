+^ACN(CID=:,51) -delim="|" -pieces=1 -commands=S -xecute="DO ^DEPBAL1"
+^CIF(ACN=:,1) -delim="|" -pieces=1 -commands=K -xecute="DO ^CIFXNAM1"
+^EFTPAY(CID=:,SEQ=:,0) -delim="|" -pieces=3 -commands=S -xecute="DO ^EFTPAY12"
