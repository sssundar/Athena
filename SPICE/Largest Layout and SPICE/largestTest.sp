****hspice ATHENA PC Incrementor Optimization Largest Tx Sizing Tested, Code****
.include "PCIncrementorOptimizationLargest_Base.spice"
.lib "/cs/courses/cs181/model/PTM_22nm_Metal_Gate_model" cmos_models
.option post
.param sup=1V
vd vdd gnd 'sup'

****Only two signals of interest, chainStart and FINALOUTPUT****
****chainStart needs to go 0to1 and the chain is already set up to****
****simulate a 0x7FFF+1 ripple, the worst case.****

v0 chainStart gnd pwl 0 0 5n 0 5.001n 'sup' 

.tran 10p 30n

.end


