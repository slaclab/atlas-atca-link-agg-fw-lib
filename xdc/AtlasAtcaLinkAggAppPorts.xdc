##############################################################################
## This file is part of 'ATLAS ATCA LINK AGG DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Jitter Cleaner PLL Ports

set_property -dict { PACKAGE_PIN AD16 IOSTANDARD LVDS } [get_ports { fpgaToPllClkP }]
set_property -dict { PACKAGE_PIN AD15 IOSTANDARD LVDS } [get_ports { fpgaToPllClkN }]

set_property -dict { PACKAGE_PIN AH16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { pllToFpgaClkP }]
set_property -dict { PACKAGE_PIN AJ16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { pllToFpgaClkN }]

# Front Panel Clock/LED/TTL Ports

set_property -dict { PACKAGE_PIN AD6 } [get_ports { smaClkP }]
set_property -dict { PACKAGE_PIN AD5 } [get_ports { smaClkN }]

set_property -dict { PACKAGE_PIN AL10 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[0]   }]
set_property -dict { PACKAGE_PIN AM10 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[0]  }]
set_property -dict { PACKAGE_PIN AH9  IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[0] }]

set_property -dict { PACKAGE_PIN AL13 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[1]   }]
set_property -dict { PACKAGE_PIN AK12 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[1]  }]
set_property -dict { PACKAGE_PIN AL12 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[1] }]

set_property -dict { PACKAGE_PIN AH13 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { fpSpareOut }]
set_property -dict { PACKAGE_PIN AJ13 IOSTANDARD LVCMOS33           } [get_ports { fpSpareInL }]
set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVCMOS33           } [get_ports { fpTrigInL }]
set_property -dict { PACKAGE_PIN AF13 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { fpBusyOut }]

# Backplane Clocks Ports
set_property -dict { PACKAGE_PIN AM11 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { bpClkOut[0] }]
set_property -dict { PACKAGE_PIN AN11 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { bpClkOut[1] }]
set_property -dict { PACKAGE_PIN AN13 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { bpClkOut[2] }]
set_property -dict { PACKAGE_PIN AP13 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { bpClkOut[3] }]
set_property -dict { PACKAGE_PIN AP11 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { bpClkOut[4] }]
set_property -dict { PACKAGE_PIN AP10 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { bpClkOut[5] }]

set_property -dict { PACKAGE_PIN G17  IOSTANDARD LVCMOS18 } [get_ports { bpClkIn[0] }]
set_property -dict { PACKAGE_PIN G16  IOSTANDARD LVCMOS18 } [get_ports { bpClkIn[1] }]
set_property -dict { PACKAGE_PIN P26  IOSTANDARD LVCMOS18 } [get_ports { bpClkIn[2] }]
set_property -dict { PACKAGE_PIN AA32 IOSTANDARD LVCMOS18 } [get_ports { bpClkIn[3] }]
set_property -dict { PACKAGE_PIN AB32 IOSTANDARD LVCMOS18 } [get_ports { bpClkIn[4] }]
set_property -dict { PACKAGE_PIN AJ21 IOSTANDARD LVCMOS18 } [get_ports { bpClkIn[5] }]

# Front Panel QSFP+ Ports

set_property PACKAGE_PIN L29 [get_ports { qsfpEthRefClkP }]
set_property PACKAGE_PIN L30 [get_ports { qsfpEthRefClkN }]

set_property PACKAGE_PIN R29 [get_ports { qsfpRef160ClkP }]
set_property PACKAGE_PIN R30 [get_ports { qsfpRef160ClkN }]

set_property PACKAGE_PIN N29 [get_ports { qsfpPllClkP }]
set_property PACKAGE_PIN N30 [get_ports { qsfpPllClkN }]

set_property PACKAGE_PIN T31 [get_ports { qsfpTxP[0][0] }]
set_property PACKAGE_PIN T32 [get_ports { qsfpTxN[0][0] }]
set_property PACKAGE_PIN R33 [get_ports { qsfpRxP[0][0] }]
set_property PACKAGE_PIN R34 [get_ports { qsfpRxN[0][0] }]

set_property PACKAGE_PIN P31 [get_ports { qsfpTxP[0][1] }]
set_property PACKAGE_PIN P32 [get_ports { qsfpTxN[0][1] }]
set_property PACKAGE_PIN N33 [get_ports { qsfpRxP[0][1] }]
set_property PACKAGE_PIN N34 [get_ports { qsfpRxN[0][1] }]

set_property PACKAGE_PIN M31 [get_ports { qsfpTxP[0][2] }]
set_property PACKAGE_PIN M32 [get_ports { qsfpTxN[0][2] }]
set_property PACKAGE_PIN L33 [get_ports { qsfpRxP[0][2] }]
set_property PACKAGE_PIN L34 [get_ports { qsfpRxN[0][2] }] 

set_property PACKAGE_PIN K31 [get_ports { qsfpTxP[0][3] }]
set_property PACKAGE_PIN K32 [get_ports { qsfpTxN[0][3] }]
set_property PACKAGE_PIN J33 [get_ports { qsfpRxP[0][3] }]
set_property PACKAGE_PIN J34 [get_ports { qsfpRxN[0][3] }]

set_property PACKAGE_PIN H31 [get_ports { qsfpTxP[1][0] }]
set_property PACKAGE_PIN H32 [get_ports { qsfpTxN[1][0] }]
set_property PACKAGE_PIN G33 [get_ports { qsfpRxP[1][0] }]
set_property PACKAGE_PIN G34 [get_ports { qsfpRxN[1][0] }]

set_property PACKAGE_PIN G29 [get_ports { qsfpTxP[1][1] }]
set_property PACKAGE_PIN G30 [get_ports { qsfpTxN[1][1] }]
set_property PACKAGE_PIN F31 [get_ports { qsfpRxP[1][1] }]
set_property PACKAGE_PIN F32 [get_ports { qsfpRxN[1][1] }]

set_property PACKAGE_PIN D31 [get_ports { qsfpTxP[1][2] }]
set_property PACKAGE_PIN D32 [get_ports { qsfpTxN[1][2] }]
set_property PACKAGE_PIN E33 [get_ports { qsfpRxP[1][2] }]
set_property PACKAGE_PIN E34 [get_ports { qsfpRxN[1][2] }]

set_property PACKAGE_PIN B31 [get_ports { qsfpTxP[1][3] }]
set_property PACKAGE_PIN B32 [get_ports { qsfpTxN[1][3] }]
set_property PACKAGE_PIN C33 [get_ports { qsfpRxP[1][3] }]
set_property PACKAGE_PIN C34 [get_ports { qsfpRxN[1][3] }]

# Front Panel SFP+ Ports

set_property PACKAGE_PIN V6 [get_ports { sfpEthRefClkP }]
set_property PACKAGE_PIN V5 [get_ports { sfpEthRefClkN }]

set_property PACKAGE_PIN K6 [get_ports { sfpRef160ClkP }]
set_property PACKAGE_PIN K5 [get_ports { sfpRef160ClkN }]

set_property PACKAGE_PIN H6 [get_ports { sfpPllClkP }]
set_property PACKAGE_PIN H5 [get_ports { sfpPllClkN }]

set_property PACKAGE_PIN F6 [get_ports { sfpTxP[0] }]
set_property PACKAGE_PIN F5 [get_ports { sfpTxN[0] }]
set_property PACKAGE_PIN E4 [get_ports { sfpRxP[0] }]
set_property PACKAGE_PIN E3 [get_ports { sfpRxN[0] }]

set_property PACKAGE_PIN D6 [get_ports { sfpTxP[1] }]
set_property PACKAGE_PIN D5 [get_ports { sfpTxN[1] }]
set_property PACKAGE_PIN D2 [get_ports { sfpRxP[1] }]
set_property PACKAGE_PIN D1 [get_ports { sfpRxN[1] }]

set_property PACKAGE_PIN C4 [get_ports { sfpTxP[2] }]
set_property PACKAGE_PIN C3 [get_ports { sfpTxN[2] }]
set_property PACKAGE_PIN B2 [get_ports { sfpRxP[2] }]
set_property PACKAGE_PIN B1 [get_ports { sfpRxN[2] }]

set_property PACKAGE_PIN B6 [get_ports { sfpTxP[3] }]
set_property PACKAGE_PIN B5 [get_ports { sfpTxN[3] }]
set_property PACKAGE_PIN A4 [get_ports { sfpRxP[3] }]
set_property PACKAGE_PIN A3 [get_ports { sfpRxN[3] }]

# RTM-DPM[0] Ports

set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][0] }]
set_property -dict { PACKAGE_PIN G11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][0] }]

set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][1] }]
set_property -dict { PACKAGE_PIN G12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][1] }]

set_property -dict { PACKAGE_PIN K11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][2] }]
set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][2] }]

set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][3] }]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][3] }]

set_property -dict { PACKAGE_PIN L12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][4] }]
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][4] }]

set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][5] }]
set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][5] }]

set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][6] }]
set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][6] }]

set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][7] }]
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][7] }]

set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][8] }]
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][8] }]

set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][9] }]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][9] }]

set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][10] }]
set_property -dict { PACKAGE_PIN A12 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][10] }]

set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][11] }]
set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][11] }]

set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][12] }]
set_property -dict { PACKAGE_PIN F17 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][12] }]

set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][13] }]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][13] }]

set_property -dict { PACKAGE_PIN G19 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][14] }]
set_property -dict { PACKAGE_PIN F19 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][14] }]

set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[0][15] }]
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[0][15] }]

set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][0] }]
set_property -dict { PACKAGE_PIN F10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][0] }]

set_property -dict { PACKAGE_PIN G9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][1] }]
set_property -dict { PACKAGE_PIN F9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][1] }]

set_property -dict { PACKAGE_PIN K10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][2] }]
set_property -dict { PACKAGE_PIN J10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][2] }]

set_property -dict { PACKAGE_PIN J8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][3] }]
set_property -dict { PACKAGE_PIN H8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][3] }]

set_property -dict { PACKAGE_PIN J9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][4] }]
set_property -dict { PACKAGE_PIN H9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][4] }]

set_property -dict { PACKAGE_PIN L8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][5] }]
set_property -dict { PACKAGE_PIN K8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][5] }]

set_property -dict { PACKAGE_PIN E10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][6] }]
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][6] }]

set_property -dict { PACKAGE_PIN D9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][7] }]
set_property -dict { PACKAGE_PIN C9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][7] }]

set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][8] }]
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][8] }]

set_property -dict { PACKAGE_PIN D8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][9] }]
set_property -dict { PACKAGE_PIN C8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][9] }]

set_property -dict { PACKAGE_PIN B9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][10] }]
set_property -dict { PACKAGE_PIN A9 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][10] }]

set_property -dict { PACKAGE_PIN F8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][11] }]
set_property -dict { PACKAGE_PIN E8 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][11] }]

set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][12] }]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][12] }]

set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][13] }]
set_property -dict { PACKAGE_PIN D16 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][13] }]

set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][14] }]
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][14] }]

set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[0][15] }]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[0][15] }]

set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][0] }]
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][1] }]

set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][2] }]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][3] }]

set_property -dict { PACKAGE_PIN C18 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][4] }]
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][5] }]

set_property -dict { PACKAGE_PIN B17 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][6] }]
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[0][7] }]

# RTM-DPM[1] Ports

set_property -dict { PACKAGE_PIN D23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][0] }]
set_property -dict { PACKAGE_PIN C23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][0] }]

set_property -dict { PACKAGE_PIN E22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][1] }]
set_property -dict { PACKAGE_PIN E23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][1] }]

set_property -dict { PACKAGE_PIN B21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][2] }]
set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][2] }]

set_property -dict { PACKAGE_PIN C21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][3] }]
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][3] }]

set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][4] }]
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][4] }]

set_property -dict { PACKAGE_PIN D20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][5] }]
set_property -dict { PACKAGE_PIN D21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][5] }]

set_property -dict { PACKAGE_PIN G24 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][6] }]
set_property -dict { PACKAGE_PIN F25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][6] }]

set_property -dict { PACKAGE_PIN E20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][7] }]
set_property -dict { PACKAGE_PIN E21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][7] }]

set_property -dict { PACKAGE_PIN F23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][8] }]
set_property -dict { PACKAGE_PIN F24 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][8] }]

set_property -dict { PACKAGE_PIN G20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][9] }]
set_property -dict { PACKAGE_PIN F20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][9] }]

set_property -dict { PACKAGE_PIN G22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][10] }]
set_property -dict { PACKAGE_PIN F22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][10] }]

set_property -dict { PACKAGE_PIN H21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][11] }]
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][11] }]

set_property -dict { PACKAGE_PIN P24 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][12] }]
set_property -dict { PACKAGE_PIN P25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][12] }]

set_property -dict { PACKAGE_PIN T27 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][13] }]
set_property -dict { PACKAGE_PIN R27 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][13] }]

set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][14] }]
set_property -dict { PACKAGE_PIN T25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][14] }]

set_property -dict { PACKAGE_PIN R25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[1][15] }]
set_property -dict { PACKAGE_PIN R26 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[1][15] }]

set_property -dict { PACKAGE_PIN D24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][0] }]
set_property -dict { PACKAGE_PIN C24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][0] }]

set_property -dict { PACKAGE_PIN E25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][1] }]
set_property -dict { PACKAGE_PIN D25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][1] }]

set_property -dict { PACKAGE_PIN B24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][2] }]
set_property -dict { PACKAGE_PIN A24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][2] }]

set_property -dict { PACKAGE_PIN C26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][3] }]
set_property -dict { PACKAGE_PIN B26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][3] }]

set_property -dict { PACKAGE_PIN B25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][4] }]
set_property -dict { PACKAGE_PIN A25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][4] }]

set_property -dict { PACKAGE_PIN E26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][5] }]
set_property -dict { PACKAGE_PIN D26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][5] }]

set_property -dict { PACKAGE_PIN A27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][6] }]
set_property -dict { PACKAGE_PIN A28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][6] }]

set_property -dict { PACKAGE_PIN D28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][7] }]
set_property -dict { PACKAGE_PIN C28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][7] }]

set_property -dict { PACKAGE_PIN B29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][8] }]
set_property -dict { PACKAGE_PIN A29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][8] }]

set_property -dict { PACKAGE_PIN E28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][9] }]
set_property -dict { PACKAGE_PIN D29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][9] }]

set_property -dict { PACKAGE_PIN C27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][10] }]
set_property -dict { PACKAGE_PIN B27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][10] }]

set_property -dict { PACKAGE_PIN F27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][11] }]
set_property -dict { PACKAGE_PIN E27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][11] }]

set_property -dict { PACKAGE_PIN N24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][12] }]
set_property -dict { PACKAGE_PIN M24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][12] }]

set_property -dict { PACKAGE_PIN M25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][13] }]
set_property -dict { PACKAGE_PIN M26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][13] }]

set_property -dict { PACKAGE_PIN L22 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][14] }]
set_property -dict { PACKAGE_PIN K23 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][14] }]

set_property -dict { PACKAGE_PIN L25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[1][15] }]
set_property -dict { PACKAGE_PIN K25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[1][15] }]

set_property -dict { PACKAGE_PIN L23 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][0] }]
set_property -dict { PACKAGE_PIN L24 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][1] }]

set_property -dict { PACKAGE_PIN M27 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][2] }]
set_property -dict { PACKAGE_PIN L27 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][3] }]

set_property -dict { PACKAGE_PIN J23 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][4] }]
set_property -dict { PACKAGE_PIN H24 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][5] }]

set_property -dict { PACKAGE_PIN J26 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][6] }]
set_property -dict { PACKAGE_PIN H26 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[1][7] }]

# RTM-DPM[2] Ports

set_property -dict { PACKAGE_PIN W23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][0] }]
set_property -dict { PACKAGE_PIN W24 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][0] }]

set_property -dict { PACKAGE_PIN W25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][1] }]
set_property -dict { PACKAGE_PIN Y25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][1] }]

set_property -dict { PACKAGE_PIN U21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][2] }]
set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][2] }]

set_property -dict { PACKAGE_PIN V22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][3] }]
set_property -dict { PACKAGE_PIN V23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][3] }]

set_property -dict { PACKAGE_PIN T22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][4] }]
set_property -dict { PACKAGE_PIN T23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][4] }]

set_property -dict { PACKAGE_PIN V21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][5] }]
set_property -dict { PACKAGE_PIN W21 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][5] }]

set_property -dict { PACKAGE_PIN V27 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][6] }]
set_property -dict { PACKAGE_PIN V28 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][6] }]

set_property -dict { PACKAGE_PIN U24 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][7] }]
set_property -dict { PACKAGE_PIN U25 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][7] }]

set_property -dict { PACKAGE_PIN W28 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][8] }]
set_property -dict { PACKAGE_PIN Y28 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][8] }]

set_property -dict { PACKAGE_PIN U26 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][9] }]
set_property -dict { PACKAGE_PIN U27 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][9] }]

set_property -dict { PACKAGE_PIN V29 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][10] }]
set_property -dict { PACKAGE_PIN W29 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][10] }]

set_property -dict { PACKAGE_PIN V26 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][11] }]
set_property -dict { PACKAGE_PIN W26 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][11] }]

set_property -dict { PACKAGE_PIN AB30 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][12] }]
set_property -dict { PACKAGE_PIN AB31 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][12] }]

set_property -dict { PACKAGE_PIN AC34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][13] }]
set_property -dict { PACKAGE_PIN AD34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][13] }]

set_property -dict { PACKAGE_PIN AA29 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][14] }]
set_property -dict { PACKAGE_PIN AB29 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][14] }]

set_property -dict { PACKAGE_PIN AA34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[2][15] }]
set_property -dict { PACKAGE_PIN AB34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[2][15] }]

set_property -dict { PACKAGE_PIN AA24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][0] }]
set_property -dict { PACKAGE_PIN AA25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][0] }]

set_property -dict { PACKAGE_PIN Y23  IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][1] }]
set_property -dict { PACKAGE_PIN AA23 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][1] }]

set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][2] }]
set_property -dict { PACKAGE_PIN AC21 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][2] }]

set_property -dict { PACKAGE_PIN AA20 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][3] }]
set_property -dict { PACKAGE_PIN AB20 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][3] }]

set_property -dict { PACKAGE_PIN AC22 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][4] }]
set_property -dict { PACKAGE_PIN AC23 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][4] }]

set_property -dict { PACKAGE_PIN AA22 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][5] }]
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][5] }]

set_property -dict { PACKAGE_PIN AB25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][6] }]
set_property -dict { PACKAGE_PIN AB26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][6] }]

set_property -dict { PACKAGE_PIN AA27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][7] }]
set_property -dict { PACKAGE_PIN AB27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][7] }]

set_property -dict { PACKAGE_PIN AC26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][8] }]
set_property -dict { PACKAGE_PIN AC27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][8] }]

set_property -dict { PACKAGE_PIN AB24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][9] }]
set_property -dict { PACKAGE_PIN AC24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][9] }]

set_property -dict { PACKAGE_PIN AD25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][10] }]
set_property -dict { PACKAGE_PIN AD26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][10] }]

set_property -dict { PACKAGE_PIN Y26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][11] }]
set_property -dict { PACKAGE_PIN Y27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][11] }]

set_property -dict { PACKAGE_PIN AC31 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][12] }]
set_property -dict { PACKAGE_PIN AC32 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][12] }]

set_property -dict { PACKAGE_PIN AD30 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][13] }]
set_property -dict { PACKAGE_PIN AD31 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][13] }]

set_property -dict { PACKAGE_PIN AE33 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][14] }]
set_property -dict { PACKAGE_PIN AF34 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][14] }]

set_property -dict { PACKAGE_PIN AE32 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[2][15] }]
set_property -dict { PACKAGE_PIN AF32 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[2][15] }]

set_property -dict { PACKAGE_PIN AF33 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][0] }]
set_property -dict { PACKAGE_PIN AG34 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][1] }]

set_property -dict { PACKAGE_PIN AG31 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][2] }]
set_property -dict { PACKAGE_PIN AG32 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][3] }]

set_property -dict { PACKAGE_PIN AF30 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][4] }]
set_property -dict { PACKAGE_PIN AG30 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][5] }]

set_property -dict { PACKAGE_PIN AD29 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][6] }]
set_property -dict { PACKAGE_PIN AE30 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[2][7] }]


# RTM-DPM[3] Ports

set_property -dict { PACKAGE_PIN AJ29 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][0] }]
set_property -dict { PACKAGE_PIN AK30 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][0] }]

set_property -dict { PACKAGE_PIN AK31 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][1] }]
set_property -dict { PACKAGE_PIN AK32 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][1] }]

set_property -dict { PACKAGE_PIN AJ30 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][2] }]
set_property -dict { PACKAGE_PIN AJ31 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][2] }]

set_property -dict { PACKAGE_PIN AH33 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][3] }]
set_property -dict { PACKAGE_PIN AJ33 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][3] }]

set_property -dict { PACKAGE_PIN AH31 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][4] }]
set_property -dict { PACKAGE_PIN AH32 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][4] }]

set_property -dict { PACKAGE_PIN AH34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][5] }]
set_property -dict { PACKAGE_PIN AJ34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][5] }]

set_property -dict { PACKAGE_PIN AL32 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][6] }]
set_property -dict { PACKAGE_PIN AL33 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][6] }]

set_property -dict { PACKAGE_PIN AN33 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][7] }]
set_property -dict { PACKAGE_PIN AP33 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][7] }]

set_property -dict { PACKAGE_PIN AN31 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][8] }]
set_property -dict { PACKAGE_PIN AP31 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][8] }]

set_property -dict { PACKAGE_PIN AN34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][9] }]
set_property -dict { PACKAGE_PIN AP34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][9] }]

set_property -dict { PACKAGE_PIN AM32 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][10] }]
set_property -dict { PACKAGE_PIN AN32 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][10] }]

set_property -dict { PACKAGE_PIN AL34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][11] }]
set_property -dict { PACKAGE_PIN AM34 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][11] }]

set_property -dict { PACKAGE_PIN AK22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][12] }]
set_property -dict { PACKAGE_PIN AK23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][12] }]

set_property -dict { PACKAGE_PIN AL20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][13] }]
set_property -dict { PACKAGE_PIN AM20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][13] }]

set_property -dict { PACKAGE_PIN AJ20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][14] }]
set_property -dict { PACKAGE_PIN AK20 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][14] }]

set_property -dict { PACKAGE_PIN AL22 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmP[3][15] }]
set_property -dict { PACKAGE_PIN AL23 IOSTANDARD LVCMOS18 } [get_ports { dpmToRtmN[3][15] }]

set_property -dict { PACKAGE_PIN AL30 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][0] }]
set_property -dict { PACKAGE_PIN AM30 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][0] }]

set_property -dict { PACKAGE_PIN AL29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][1] }]
set_property -dict { PACKAGE_PIN AM29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][1] }]

set_property -dict { PACKAGE_PIN AN29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][2] }]
set_property -dict { PACKAGE_PIN AP30 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][2] }]

set_property -dict { PACKAGE_PIN AN27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][3] }]
set_property -dict { PACKAGE_PIN AN28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][3] }]

set_property -dict { PACKAGE_PIN AP28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][4] }]
set_property -dict { PACKAGE_PIN AP29 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][4] }]

set_property -dict { PACKAGE_PIN AN26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][5] }]
set_property -dict { PACKAGE_PIN AP26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][5] }]

set_property -dict { PACKAGE_PIN AJ28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][6] }]
set_property -dict { PACKAGE_PIN AK28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][6] }]

set_property -dict { PACKAGE_PIN AH27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][7] }]
set_property -dict { PACKAGE_PIN AH28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][7] }]

set_property -dict { PACKAGE_PIN AL27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][8] }]
set_property -dict { PACKAGE_PIN AL28 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][8] }]

set_property -dict { PACKAGE_PIN AK26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][9] }]
set_property -dict { PACKAGE_PIN AK27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][9] }]

set_property -dict { PACKAGE_PIN AM26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][10] }]
set_property -dict { PACKAGE_PIN AM27 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][10] }]

set_property -dict { PACKAGE_PIN AH26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][11] }]
set_property -dict { PACKAGE_PIN AJ26 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][11] }]

set_property -dict { PACKAGE_PIN AH22 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][12] }]
set_property -dict { PACKAGE_PIN AH23 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][12] }]

set_property -dict { PACKAGE_PIN AJ23 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][13] }]
set_property -dict { PACKAGE_PIN AJ24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][13] }]

set_property -dict { PACKAGE_PIN AH24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][14] }]
set_property -dict { PACKAGE_PIN AJ25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][14] }]

set_property -dict { PACKAGE_PIN AG24 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmP[3][15] }]
set_property -dict { PACKAGE_PIN AG25 IOSTANDARD LVCMOS18 } [get_ports { rtmToDpmN[3][15] }]

set_property -dict { PACKAGE_PIN AF23 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][0] }]
set_property -dict { PACKAGE_PIN AF24 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][1] }]

set_property -dict { PACKAGE_PIN AE25 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][2] }]
set_property -dict { PACKAGE_PIN AE26 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][3] }]

set_property -dict { PACKAGE_PIN AF22 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][4] }]
set_property -dict { PACKAGE_PIN AG22 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][5] }]

set_property -dict { PACKAGE_PIN AE22 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][6] }]
set_property -dict { PACKAGE_PIN AE23 IOSTANDARD LVCMOS18 } [get_ports { rtmIo[3][7] }]
