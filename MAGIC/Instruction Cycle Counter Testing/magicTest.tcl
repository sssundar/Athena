stepsize 100
vector clk phi0 phi0_ phi1 phi1_
vector ICC ICC2 ICC1 ICC0
vector RST RESET RESET_
vector cnt iccB1 iccB0 
vector cnt_ iccB1_ iccB0_
w clk ICC RST BranchInstruction INC cnt cnt_
clock clk 0101 0110 0101 1001
setvector RST 10
l BranchInstruction
p
p
c
setvector RST 01
c
c
h BranchInstruction
c
c
c

| instructionCycleCounter works
