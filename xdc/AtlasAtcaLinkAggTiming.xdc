##############################################################################
## This file is part of 'ATLAS ATCA LINK AGG DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

###############
# Common Clocks
###############

create_clock -name baseEthRefClkP -period 1.600 [get_ports { ethRefClkP[0] }]
create_clock -name fpEthRefClkP   -period 1.600 [get_ports { ethRefClkP[1] }]

create_clock -name fabEthRefClkP  -period 6.400 [get_ports { fabEthRefClkP }]

create_clock -name qsfpEthRefClkP -period 6.400 [get_ports { qsfpEthRefClkP }]
# create_clock -name qsfpRef160ClkP -period 6.237 [get_ports { qsfpRef160ClkP }]
create_clock -name qsfpRef160ClkP -period 6.400 [get_ports { qsfpRef160ClkP }]; # Debugging only!!!!

create_clock -name sfpEthRefClkP  -period 6.400 [get_ports { sfpEthRefClkP }]
# create_clock -name sfpRef160ClkP  -period 6.237 [get_ports { sfpRef160ClkP }]
create_clock -name sfpRef160ClkP  -period 6.400 [get_ports { sfpRef160ClkP }]; # Debugging only!!!!

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {baseEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {fpEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {fabEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {qsfpEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {qsfpRef160ClkP}] \
   -group [get_clocks -include_generated_clocks {sfpEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {sfpRef160ClkP}]

create_generated_clock -name axilClk   [get_pins U_Core/U_ClkRst/GEN_REAL.U_PLL/CLKOUT0]
create_generated_clock -name eth125Clk [get_pins U_Core/U_ClkRst/GEN_REAL.U_PLL/CLKOUT1] 
create_generated_clock -name eth62Clk  [get_pins {U_Core/U_ClkRst/U_eth62Clk/O}] 

set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {eth125Clk}]
set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {eth62Clk}]

#########################################################
# Front Panel at 10/100/1000 & BASE ETH[1] at 10/100/1000
#########################################################

create_generated_clock -name baseEthClk625 [get_pins {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_PLL/CLKOUT0}] 
create_generated_clock -name baseEthClk312 [get_pins {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_PLL/CLKOUT1}] 
create_generated_clock -name baseEthClk125 [get_pins {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_sysClk125/O}]

create_generated_clock -name fpEthClk625 [get_pins {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_PLL/CLKOUT0}] 
create_generated_clock -name fpEthClk312 [get_pins {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_PLL/CLKOUT1}] 
create_generated_clock -name fpEthClk125 [get_pins {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_sysClk125/O}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_SGMII[*].EN_ETH.U_Eth/U_1GigE/U_Bufg_sgmiiClk/O}]] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_SGMII[*].EN_ETH.U_Eth/U_1GigE/U_PLL/CLKOUT1}]]

set_clock_groups -asynchronous -group [get_clocks {baseEthClk312}] -group [get_clocks {baseEthClk125}]
set_clock_groups -asynchronous -group [get_clocks {fpEthClk312}]   -group [get_clocks {fpEthClk125}]

set_property CLOCK_DELAY_GROUP BASE_ETH_CLK_GRP [get_nets {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/sysClk312}] [get_nets {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/sysClk625}]
set_property CLOCK_DELAY_GROUP FP_ETH_CLK_GRP   [get_nets {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/sysClk312}] [get_nets {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/sysClk625}]

create_pblock SGMII_ETH_BLK
add_cells_to_pblock [get_pblocks SGMII_ETH_BLK] [get_cells {U_Core/U_Eth/GEN_SGMII[*].EN_ETH/U_Eth/U_1GigE}]
resize_pblock       [get_pblocks SGMII_ETH_BLK] -add {CLOCKREGION_X2Y0:CLOCKREGION_X2Y0}

set_property LOC PLL_X0Y0        [get_cells {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_PLL}]
set_property LOC BUFGCE_X0Y13    [get_cells {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_sysClk625}]
set_property LOC BUFGCE_X0Y12    [get_cells {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_sysClk312}]
set_property LOC BUFGCE_DIV_X0Y3 [get_cells {U_Core/U_Eth/GEN_SGMII[0].EN_ETH.U_Eth/U_1GigE/U_sysClk125}]

set_property LOC PLL_X0Y1        [get_cells {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_PLL}]
set_property LOC BUFGCE_X0Y20    [get_cells {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_sysClk625}]
set_property LOC BUFGCE_X0Y14    [get_cells {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_sysClk312}]
set_property LOC BUFGCE_DIV_X0Y2 [get_cells {U_Core/U_Eth/GEN_SGMII[1].EN_ETH.U_Eth/U_1GigE/U_sysClk125}]

################################################
# FABRIC ETH[1:4] at 1GbE x 1 Lane (1000BASE-KX)
################################################

create_generated_clock -name fabEth1GbETxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbETxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbETxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbETxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbERxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth1GbERxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth1GbERxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth1GbERxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
set_clock_groups -asynchronous -group [get_clocks {eth62Clk}] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

###################################################################
# FABRIC ETH[1:4] at 10GbE x 4 Lane (10GBASE-KX4 ... A.K.A. "XAUI")
###################################################################

create_generated_clock -name fabEthXauiTxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEthXauiTxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEthXauiTxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEthXauiTxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]

create_generated_clock -name fabEthXauiRxClk0_0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk0_1 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk0_2 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk0_3 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]

create_generated_clock -name fabEthXauiRxClk1_0 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk1_1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk1_2 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk1_3 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]

create_generated_clock -name fabEthXauiRxClk2_0 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk2_1 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk2_2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk2_3 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]

create_generated_clock -name fabEthXauiRxClk3_0 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk3_1 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk3_2 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEthXauiRxClk3_3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {fabEthRefClkP}] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx4.U_Eth/XauiGthUltraScale_Inst/U_XauiGthUltraScaleCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

################################################
# FABRIC ETH[1:4] at 10GbE x 1 Lane (10GBASE-KR)
################################################

create_generated_clock -name fabEth10GbETxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]
create_generated_clock -name fabEth10GbETxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]
create_generated_clock -name fabEth10GbETxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]
create_generated_clock -name fabEth10GbETxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]

create_generated_clock -name fabEth10GbERxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]
create_generated_clock -name fabEth10GbERxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]
create_generated_clock -name fabEth10GbERxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]
create_generated_clock -name fabEth10GbERxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]

create_generated_clock -name fabEth10GbERxPcsClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth10GbERxPcsClk0 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth10GbERxPcsClk0 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth10GbERxPcsClk0 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]

set_clock_groups -asynchronous \
   -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] \
   -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]] \
   -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_10Gx1.U_Eth/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] \
   -group [get_clocks -of_objects [get_pins U_Core/U_ClkRst/GEN_REAL.U_PLL/CLKOUT0]]
