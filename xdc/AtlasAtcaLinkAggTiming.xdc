##############################################################################
## This file is part of 'ATLAS ATCA LINK AGG DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Common Clocks

create_clock -name baseEthRefClkP -period 1.600 [get_ports {baseEthRefClkP}]

create_clock -name fabEthRefClkP  -period 6.400 [get_ports {fabEthRefClkP}]

create_clock -name qsfpEthRefClkP -period 6.400 [get_ports {qsfpEthRefClkP}]
create_clock -name qsfpRef160ClkP -period 6.237 [get_ports {qsfpRef160ClkP}]

create_clock -name sfpEthRefClkP  -period 6.400 [get_ports {sfpEthRefClkP}]
create_clock -name sfpRef160ClkP  -period 6.237 [get_ports {sfpRef160ClkP}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {baseEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {fabEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {qsfpEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {qsfpRef160ClkP}] \
   -group [get_clocks -include_generated_clocks {sfpEthRefClkP}] \
   -group [get_clocks -include_generated_clocks {sfpRef160ClkP}]

create_generated_clock -name axilClk   [get_pins {U_Core/U_ClkRst/U_Pll/PllGen.U_Pll/CLKOUT0}] 
create_generated_clock -name eth125Clk [get_pins {U_Core/U_ClkRst/U_Pll/PllGen.U_Pll/CLKOUT1}] 
create_generated_clock -name eth62Clk  [get_pins {U_Core/U_ClkRst/U_eth62Clk/O}] 

set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {eth125Clk}]
set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {eth62Clk}]

# Front Panel LVDS SGMII Ports at 1GbE (1000BASE-KX)

create_generated_clock -name fpEthClkTx0 [get_pins {U_Core/U_Eth/GEN_FP.U_Eth/U_CLK/Clk_Rst_I_Plle3_Tx/CLKOUT0}] 
create_generated_clock -name fpEthClkTx1 [get_pins {U_Core/U_Eth/GEN_FP.U_Eth/U_CLK/Clk_Rst_I_Plle3_Tx/CLKOUT1}] 
create_generated_clock -name fpEthClkRx0 [get_pins {U_Core/U_Eth/GEN_FP.U_Eth/U_CLK/Clk_Rst_I_Plle3_Rx/CLKOUT0}] 
create_generated_clock -name fpEthClkRx1 [get_pins {U_Core/U_Eth/GEN_FP.U_Eth/U_CLK/Clk_Rst_I_Plle3_Rx/CLKOUT1}] 
set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {fpEthClkTx0}]
set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {fpEthClkTx1}]
set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {fpEthClkRx0}]
set_clock_groups -asynchronous -group [get_clocks {axilClk}] -group [get_clocks {fpEthClkRx1}]

# BASE ETH[1] at 10/100/1000

create_generated_clock -name baseEthClk0 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT0}] 
create_generated_clock -name baseEthClk1 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT1}] 
create_generated_clock -name baseEthClk2 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT2}] 
create_generated_clock -name baseEthClk3 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT3}] 
create_generated_clock -name baseEthClk4 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT4}] 
create_generated_clock -name baseEthClk5 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT5}] 
create_generated_clock -name baseEthClk6 [get_pins {U_Core/U_Eth/GEN_BASE.U_Eth/U_1GigE/U_MMCM/CLKOUT6}] 

# FABRIC ETH[1:4] at 1GbE x 1 Lane (1000BASE-KX)

create_generated_clock -name fabEth1GbETxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbETxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbETxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbETxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name fabEth1GbERxClk0 [get_pins {U_Core/U_Eth/GEN_FAB[0].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth1GbERxClk1 [get_pins {U_Core/U_Eth/GEN_FAB[1].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth1GbERxClk2 [get_pins {U_Core/U_Eth/GEN_FAB[2].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name fabEth1GbERxClk3 [get_pins {U_Core/U_Eth/GEN_FAB[3].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
set_clock_groups -asynchronous -group [get_clocks {eth62Clk}] -group [get_clocks -of_objects [get_pins {U_Core/U_Eth/GEN_FAB[*].EN_ETH.U_Fab/GEN_ETH_1Gx1.U_Eth/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

# FABRIC ETH[1:4] at 10GbE x 4 Lane (10GBASE-KX4 ... A.K.A. "XAUI")

# FABRIC ETH[1:4] at 10GbE x 1 Lane (10GBASE-KR)
