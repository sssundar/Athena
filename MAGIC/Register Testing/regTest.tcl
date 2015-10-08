vector clk phi0 phi1
clock clk 00 10 00 01
vector dataPath dp7 dp6 dp5 dp4 dp3 dp2 dp1 dp0
vector output op7 op6 op5 op4 op3 op2 op1 op0
vector RW simpleRead simpleWrite
vector ID RegisterReadID RegisterWriteID

w output dataPath ID RW clk

setvector dataPath 00000000
setvector RW 00
setvector ID 00
c

setvector RW 11
setvector ID 00
c

setvector RW 01
setvector ID 01
c

setvector RW 10
setvector ID 00
c

setvector RW 10
setvector ID 01
c

setvector RW 10
setvector ID 10
c



 

