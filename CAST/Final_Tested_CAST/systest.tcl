| Sushant Sundaresh & Brian Kubisiak 
| Last Modified: June 11, 2015
| ATHENA CAST System Test. 

| For Reference, testing started June 10, 2015, 9 PM, and CAST debugging completed, June 11, 2015, 5 PM. 
| The ATHENA design process (excluding layout) thus took from May 22nd (started bouncing ideas around for a project)
| to June 11 (CAST design completed). 

| Before running this script, type in a terminal, from
| a directory with all CAST files for the ATHENA,
| prs2sim athenaTest.cast
| irsim athenaTest.sim
| @ systest.tcl

| Please see http://opencircuitdesign.com/irsim/archive/irsim.pdf for help.

| Set step size
stepsize 50

| Setup Clock and Ties to Rails
vector clk phi0 phi0_ phi1 phi1_
clock clk 0101 1001 0101 0110 
vector KONST ALWAYSHIGH ALWAYSLOW
setvector KONST 10

| Set RESET low to start
l RESET

| Setup Watches
vector RST RESET RESET_
vector I in7 in6 in5 in4 in3 in2 in1 in0
vector O out7 out6 out5 out4 out3 out2 out1 out0
vector ADR addr14 addr13 addr12 addr11 addr10 addr9 addr8 addr7 addr6 addr5 addr4 addr3 addr2 addr1 addr0
vector DP dataPath7 dataPath6 dataPath5 dataPath4 dataPath3 dataPath2 dataPath1 dataPath0
vector CP controlPath7 controlPath6 controlPath5 controlPath4 controlPath3 controlPath2 controlPath1 controlPath0
vector CP_ controlPath_7 controlPath_6 controlPath_5 controlPath_4 controlPath_3 controlPath_2 controlPath_1 controlPath_0
vector R0 reg07 reg06 reg05 reg04 reg03 reg02 reg01 reg00
vector R1 reg17 reg16 reg15 reg14 reg13 reg12 reg11 reg10
vector R2 reg27 reg26 reg25 reg24 reg23 reg22 reg21 reg20
vector R3 reg37 reg36 reg35 reg34 reg33 reg32 reg31 reg30
vector R4 reg47 reg46 reg45 reg44 reg43 reg42 reg41 reg40
vector R5 reg57 reg56 reg55 reg54 reg53 reg52 reg51 reg50
vector R6 reg67 reg66 reg65 reg64 reg63 reg62 reg61 reg60
vector R7 reg77 reg76 reg75 reg74 reg73 reg72 reg71 reg70
vector PWMCOUNT pwmc7 pwmc6 pwmc5 pwmc4 pwmc3 pwmc2 pwmc1 pwmc0
vector ICC iccB1 iccB0
vector ICCFlags instructionCycleCountIs2 instructionCycleCountIs1 instructionCycleCountIs0
vector BIOASLP BranchInstruction InputInstruction OutputInstruction ArithmeticInstruction ShiftInstruction LogicalInstruction PWMInstruction
vector RW simpleRead simpleWrite
vector REGRD Register0Read Register1Read Register2Read Register3Read Register4Read Register5Read Register6Read Register7Read
vector REGWR Register0Write Register1Write Register2Write Register3Write Register4Write Register5Write Register6Write Register7Write
vector BRFLAGS latchedCarryOut logicalAccumulatorIs0
vector EXTRNSIG memselect addrselect datawrite
w clk R0 R1 R2 R3 R4 R5 R6 R7 PWMCOUNT EXTRNSIG REGRD REGWR RW BRFLAGS BIOASLP ICC ICCFlags RST I O ADR DP CP CP_ pwmOut

| RESET and CLOCK SYNC Order Important
| Phase shift clock to start of phi1. 
| Then reset ATHENA for one full clock.

p
p
p
h RESET
c
l RESET

 									| System Test Program Overview
									| Test CIN to load 0 
									| Use MOV to sequentially clear all regs 7->6->..->0
 									| Test ADDR to set DataIn address and addrselect line
									| Test IN to load up all regs differently (tests memselect, too)
 									| Then test OUT (for dataWrite)
									| Test MOV on R0->R7
									| Test ADD with to set a carry out 0/1, test cout flag
									| Test BRC 
									| Then test JMP
									| Test SUB and effect on carry flag
									| Then test logical instructions, to set l = 0/1 and test Z flag
									| Then test BRZ
 									| Then test shifting instructions
 									| Then test PWM
										
| 
| BEGIN TEST PROGRAM
| 

									| Test CIN to load 0 
 			 						| CIN d111 
									| 00000000

setvector I 01010111  	
c
 									| ADR should be at 0x0001
 									| ICC should be 00
assert ADR 000000000000001
assert ICC 00

setvector I 00000000
c
 									| REG7 should be cleared
 									| ADR should be at 0x0002, CIN is a two byte
 									| ICC should be 01 	   two clock instruction
assert R7 00000000
assert ADR 000000000000010
assert ICC 01

									| Use MOV to sequentially clear all regs 7->6->..->0
									| MOV d110, r111
setvector I 11111110
c 1
									| check if CP really latched, and if INPUTREG blocked.
setvector I 00110011 							
p
p
p
p
 									| MOV is a single byte
 									| two clock instruction
assert ADR 000000000000011 					
assert ICC 01 									
assert R6 00000000

									| MOV d101, r110
setvector I 11110101 
c 2
assert R5 00000000
assert ADR 000000000000100 					
									| MOV d100, r101
setvector I 11101100 
c 2
assert R4 00000000
assert ADR 000000000000101
									| MOV d011, r100
setvector I 11100011 
c 2
assert R3 00000000
assert ADR 000000000000110
									| MOV d010, r011
setvector I 11011010 
c 2
assert R2 00000000
assert ADR 000000000000111
									| MOV d001, r010
setvector I 11010001 
c 2
assert R1 00000000
assert ADR 000000000001000
									| MOV d000, r001
setvector I 11001000
c 2
assert R0 00000000
assert ADR 000000000001001 						
									| Trust ADR from now on till BRZ/C JMP tests
 									| Test ADDR to set DataIn address and addrselect line
									| ADDR r000		
setvector I 10000011
c 1
p
assert EXTRNSIG 000 							
									| addrselect should be low on phi1 
p
p 	
									| on phi0 expect addrselect high with proper out bus
assert EXTRNSIG 010
assert O 00000000
p
assert EXTRNSIG 000 							
									| addrselect should go low again

									| Test IN to load up all regs differently (tests memselect, too)
									| Do not bother setting true addresses, just pretend proper bytes 
									| find themselves onto the data memory output bus if memselect is
									| set properly.

									| IN d000
setvector I 01001000
c
p
assert EXTRNSIG 100
setvector I 00000001
s
 									| check memselect = 1 (data)
 									| set data in as 0x01
p
p
p
									| R0 should have 0x01
 									| should help with testing arithmetic accumulator
assert R0 00000001

									| IN d001
setvector I 01001001
c
p
assert EXTRNSIG 100
setvector I 10101010
s
 									| check memselect = 1 (data)
 									| set data in as 10101010
p
p
p
									| R1 should have 10101010
 									| should help with testing logical accumulator
assert R1 10101010

									| IN d010
setvector I 01001010
c
p
assert EXTRNSIG 100
setvector I 01010101
s
 									| check memselect = 1 (data)
 									| set data in as 01010101
p
p
p
									| R2 should have 01010101
 									| should help with testing logical accumulator
assert R2 01010101

									| IN d011
setvector I 01001011
c
p
assert EXTRNSIG 100
setvector I 00001000
s
 									| check memselect = 1 (data)
 									| set data in as 01010101
p
p
p
									| R3 should have 00001000
 									| should help with testing pwm
assert R3 00001000

									| IN d110
setvector I 01001110
c
p
assert EXTRNSIG 100
setvector I 11111111
s
 									| check memselect = 1 (data)
 									| set data in as 11111111
p
p
p
									| R6 should have 11111111
 									| should help with testing brc
assert R6 11111111

 									| Then test OUT (for dataWrite)
									| OUT r011		
setvector I 10011010
c
p
assert EXTRNSIG 000
assert O 00001000 					
 									| test datawrite only on phi0 but output stabilizes on phi1
p
p
assert EXTRNSIG 001
p
									| Test MOV on R0->R7
setvector I 11000111
c 2
assert R7 00000001
									| Test ADD/SUB, set a carry out 0, test cout flag

									| Test ADD R0=a, 111	
setvector I 10111000
c 2
setvector I 00000000 							
c 2
									| equivalent of a NOP instruction (nothing should happen)
									| gives latched carry out time to update (normally, 
									| would happen in cycle0 of next instruction (no problem for BRC)
									| but this is just for easier testing.

assert BRFLAGS 00
									| test accumulator function
assert R0 00000010
assert R7 00000001

									| Test BRC with C = 0
									| Check addresses again.
assert ADR 000000000010011
 									| BRC
setvector I 00100100
c 1
assert ADR 000000000010100
c 1
assert ADR 000000000010101
c 1
assert ADR 000000000010110
assert ICC 10
 									| no branch expected but ICC 2 expected.



									| Test ADD/SUB, set a carry out 1. test by checking branching.

									| Test ADD R0=a (0x02), R6=110 (0xFF)
setvector I 10110000
c 2
setvector I 00000000 							
c 2
									| equivalent of a NOP instruction (nothing should happen)
									| gives latched carry out time to update (normally, 
									| would happen in cycle0 of next instruction (no problem for BRC)
									| but this is just for easier testing.

assert BRFLAGS 10
									| test accumulator function
assert R0 00000001

									| Test BRC with C = 1
									| Check addresses again
assert ADR 000000000011000
 									| BRC
setvector I 00100100
c 1
setvector I 00000000
assert ADR 000000000011001
c 1
setvector I 11111111
assert ADR 000000000011010
c 1
assert ADR 000000011111111
assert ICC 10
 									| branch expected and ICC 2 expected.


									| Then test JMP
setvector I 00110000
c 1
setvector I 11111111
c 1
setvector I 00000000
c 1
assert ADR 111111100000000

									| Test SUB and effect on carry flag
									| First clear carry flag.
		 							| ADD a, r7 = 0x02, no carry.
setvector I 10111000
c 2
setvector I 00000000
c 2
assert R0 00000010
assert BRFLAGS 00
									| SUB a = R0 = 0x02, r = R7 = 0x01. Expect R0 = 1, cout = 1 
setvector I 10111001 							
c 2
setvector I 00000000
c 2
assert R0 00000001
assert BRFLAGS 10 							
									| Then test logical instructions, to set l = 0/1 and test Z flag
									| First, with the carry flag set and the z flag cleared, test BRZ.

 									| BRZ
assert ADR 111111100000100
setvector I 00101000
c 1
setvector I 00110011
c 1
setvector I 11001100
c 1
assert ADR 111111100000111
 									| no branch expected

									| Then XOR l, R1 to yield 0 and set the Z flag.
setvector I 10001110
c 2
assert BRFLAGS 11
									| Then test BRZ again.

 									| BRZ
setvector I 00101000
c 1
setvector I 00110011
c 1
setvector I 11001100
c 1
assert ADR 011001111001100
 									| branch expected

									| Then test OR with R6 = 0xFF and l = 0.
setvector I 10110101
c 2
assert R1 11111111
									| then AND R6 with l to get no change,
setvector I 10110100
c 2
assert R1 11111111
									| then clear l with XOR R1 and AND R6 again.
setvector I 10001110
c 2 
assert R1 00000000
setvector I 10110100
c 2
assert R1 00000000
 									| Then test shifting instructions

assert R2 01010101
									| LSR s
setvector I 00000010 							
c 2
assert R2 00101010
									| ASR s
setvector I 00000011 
c 2
assert R2 00010101
									| MOV R6 into s to get sign 1
setvector I 11110010
c 2

assert R2 11111111
									| ASR s
setvector I 00000011 
c 2
assert R2 11111111
									| LSR s
setvector I 00000010 							
c 2
assert R2 01111111

 									| Then test PWM
									| R3 (pwm duty cycle) is 8.
									| apply nops  till pwm cntr goes to 252
									| current count is 01010011
									| pwm output has been disabled on reset
assert pwmOut 0
setvector I 00000000 
c 169
									| PWMA
setvector I 00011000
c 2
 									| now we should have pwmOut 0 (R3 = 0x08, pwmCount = 254)
setvector I 00000000
c 2 			
 									| now we should have pwmOut = 1 (R3 = 8, pwmCount = 0)
assert pwmOut 1
c 7 
assert pwmOut 1
c 1 
assert pwmOut 0 	
									| duty cycle met, even though active output, output goes low.
c 248 		
									| get us back to 0 count so output goes high again.
assert pwmOut 1
c 1				
									| now we are aligned with an instruction cycle start again 										| now disable output to show we can.
									| PWMD 		
setvector I 00010100
c 2
assert pwmOut 0
									| and show it stays disabled just like it stayed enabled before.
setvector I 00000000
c 2
assert pwmOut 0

									| 
									| End CAST system test. 
									| 
