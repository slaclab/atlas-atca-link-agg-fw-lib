##############################################################################
## This file is part of 'ATLAS ATCA LINK AGG DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1     [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE No   [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0    [current_design] 
set_property CFGBVS         {GND}                [current_design]
set_property CONFIG_VOLTAGE {1.8}                [current_design]

set_property SEVERITY {Warning} [get_drc_checks {NSTD-1}]
set_property SEVERITY {Warning} [get_drc_checks {UCIO-1}]

set_property -dict { PACKAGE_PIN V12 IOSTANDARD ANALOG } [get_ports { vPIn }]
set_property -dict { PACKAGE_PIN W11 IOSTANDARD ANALOG } [get_ports { vNIn }]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# Jitter Cleaner PLL Ports

set_property -dict { PACKAGE_PIN AE18 IOSTANDARD LVCMOS18 } [get_ports { pllSpiOeL   }];
set_property -dict { PACKAGE_PIN AF18 IOSTANDARD LVCMOS18 } [get_ports { pllSpiRstL  }];
set_property -dict { PACKAGE_PIN AF15 IOSTANDARD LVCMOS18 } [get_ports { pllIntrL    }];
set_property -dict { PACKAGE_PIN AF14 IOSTANDARD LVCMOS18 } [get_ports { pllLolL     }];

set_property -dict { PACKAGE_PIN AM16 IOSTANDARD LVCMOS18 } [get_ports { pllSpiSclk  }];
set_property -dict { PACKAGE_PIN AM15 IOSTANDARD LVCMOS18 } [get_ports { pllSpiSdi   }];
set_property -dict { PACKAGE_PIN AN18 IOSTANDARD LVCMOS18 } [get_ports { pllSpiCsL   }];
set_property -dict { PACKAGE_PIN AN17 IOSTANDARD LVCMOS18 } [get_ports { pllSpiSdo   }];

set_property -dict { PACKAGE_PIN AF10 IOSTANDARD LVCMOS33 } [get_ports { pllClkScl }]
set_property -dict { PACKAGE_PIN AG10 IOSTANDARD LVCMOS33 } [get_ports { pllClkSda }]

# Front Panel I2C Ports

set_property -dict { PACKAGE_PIN AG11 IOSTANDARD LVCMOS33 } [get_ports { fpScl }]
set_property -dict { PACKAGE_PIN AH11 IOSTANDARD LVCMOS33 } [get_ports { fpSda }]

set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVCMOS33 } [get_ports { sfpScl[0]  }]
set_property -dict { PACKAGE_PIN AE8  IOSTANDARD LVCMOS33 } [get_ports { sfpScl[1]  }]
set_property -dict { PACKAGE_PIN AF8  IOSTANDARD LVCMOS33 } [get_ports { sfpScl[2]  }]
set_property -dict { PACKAGE_PIN AF9  IOSTANDARD LVCMOS33 } [get_ports { sfpScl[3]  }]

set_property -dict { PACKAGE_PIN AJ9  IOSTANDARD LVCMOS33 } [get_ports { sfpSda[0]  }]
set_property -dict { PACKAGE_PIN AJ8  IOSTANDARD LVCMOS33 } [get_ports { sfpSda[1]  }]
set_property -dict { PACKAGE_PIN AN8  IOSTANDARD LVCMOS33 } [get_ports { sfpSda[2]  }]
set_property -dict { PACKAGE_PIN AP8  IOSTANDARD LVCMOS33 } [get_ports { sfpSda[3]  }]

set_property -dict { PACKAGE_PIN AD8  IOSTANDARD LVCMOS33 } [get_ports { qsfpScl[0] }]
set_property -dict { PACKAGE_PIN AD10 IOSTANDARD LVCMOS33 } [get_ports { qsfpScl[1] }]

set_property -dict { PACKAGE_PIN AL9  IOSTANDARD LVCMOS33 } [get_ports { qsfpSda[0] }]
set_property -dict { PACKAGE_PIN AN9  IOSTANDARD LVCMOS33 } [get_ports { qsfpSda[1] }]

# ATCA Backplane: BASE ETH[1] Ports

set_property -dict { PACKAGE_PIN AE17 IOSTANDARD LVCMOS18 } [get_ports { ethMdio[0] }];
set_property -dict { PACKAGE_PIN AF17 IOSTANDARD LVCMOS18 } [get_ports { ethMdc[0]  }];
set_property -dict { PACKAGE_PIN AE16 IOSTANDARD LVCMOS18 } [get_ports { ethRstL[0] }];
set_property -dict { PACKAGE_PIN AE15 IOSTANDARD LVCMOS18 } [get_ports { ethIrqL[0] }];

set_property -dict { PACKAGE_PIN AJ15 IOSTANDARD LVDS } [get_ports { ethTxP[0] }]
set_property -dict { PACKAGE_PIN AJ14 IOSTANDARD LVDS } [get_ports { ethTxN[0] }]

set_property -dict { PACKAGE_PIN AH18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRxP[0] }]
set_property -dict { PACKAGE_PIN AH17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRxN[0] }]

set_property -dict { PACKAGE_PIN AK17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRefClkP[0] }]
set_property -dict { PACKAGE_PIN AK16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRefClkN[0] }]

# Front Panel LVDS SGMII Ports

set_property -dict { PACKAGE_PIN AJ18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRefClkP[1] }]
set_property -dict { PACKAGE_PIN AK18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRefClkN[1] }]

set_property -dict { PACKAGE_PIN AL18 IOSTANDARD LVDS } [get_ports { ethTxP[1] }]
set_property -dict { PACKAGE_PIN AL17 IOSTANDARD LVDS } [get_ports { ethTxN[1] }]

set_property -dict { PACKAGE_PIN AL14 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRxP[1] }]
set_property -dict { PACKAGE_PIN AM14 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { ethRxN[1] }]

set_property -dict { PACKAGE_PIN AM17 IOSTANDARD LVCMOS18 } [get_ports { ethMdio[1] }];
set_property -dict { PACKAGE_PIN AN16 IOSTANDARD LVCMOS18 } [get_ports { ethMdc[1]  }];
set_property -dict { PACKAGE_PIN AN19 IOSTANDARD LVCMOS18 } [get_ports { ethRstL[1] }];
set_property -dict { PACKAGE_PIN AP18 IOSTANDARD LVCMOS18 } [get_ports { ethIrqL[1] }];

# ATCA Backplane: FABRIC ETH[1:4]

set_property PACKAGE_PIN AB6 [get_ports { fabEthRefClkP }]
set_property PACKAGE_PIN AB5 [get_ports { fabEthRefClkN }]

# ATCA Backplane: FABRIC ETH[1]

set_property PACKAGE_PIN N4 [get_ports { fabEthTxP[1][0] }]
set_property PACKAGE_PIN N3 [get_ports { fabEthTxN[1][0] }]
set_property PACKAGE_PIN M2 [get_ports { fabEthRxP[1][0] }]
set_property PACKAGE_PIN M1 [get_ports { fabEthRxN[1][0] }]

set_property PACKAGE_PIN L4 [get_ports { fabEthTxP[1][1] }]
set_property PACKAGE_PIN L3 [get_ports { fabEthTxN[1][1] }]
set_property PACKAGE_PIN K2 [get_ports { fabEthRxP[1][1] }]
set_property PACKAGE_PIN K1 [get_ports { fabEthRxN[1][1] }]

set_property PACKAGE_PIN J4 [get_ports { fabEthTxP[1][2] }]
set_property PACKAGE_PIN J3 [get_ports { fabEthTxN[1][2] }]
set_property PACKAGE_PIN H2 [get_ports { fabEthRxP[1][2] }]
set_property PACKAGE_PIN H1 [get_ports { fabEthRxN[1][2] }]

set_property PACKAGE_PIN G4 [get_ports { fabEthTxP[1][3] }]
set_property PACKAGE_PIN G3 [get_ports { fabEthTxN[1][3] }]
set_property PACKAGE_PIN F2 [get_ports { fabEthRxP[1][3] }]
set_property PACKAGE_PIN F1 [get_ports { fabEthRxN[1][3] }]

# ATCA Backplane: FABRIC ETH[2]

set_property PACKAGE_PIN AA4 [get_ports { fabEthTxP[2][0] }]
set_property PACKAGE_PIN AA3 [get_ports { fabEthTxN[2][0] }]
set_property PACKAGE_PIN Y2  [get_ports { fabEthRxP[2][0] }]
set_property PACKAGE_PIN Y1  [get_ports { fabEthRxN[2][0] }]

set_property PACKAGE_PIN W4 [get_ports { fabEthTxP[2][1] }]
set_property PACKAGE_PIN W3 [get_ports { fabEthTxN[2][1] }]
set_property PACKAGE_PIN V2 [get_ports { fabEthRxP[2][1] }]
set_property PACKAGE_PIN V1 [get_ports { fabEthRxN[2][1] }]

set_property PACKAGE_PIN U4 [get_ports { fabEthTxP[2][2] }]
set_property PACKAGE_PIN U3 [get_ports { fabEthTxN[2][2] }]
set_property PACKAGE_PIN T2 [get_ports { fabEthRxP[2][2] }]
set_property PACKAGE_PIN T1 [get_ports { fabEthRxN[2][2] }]

set_property PACKAGE_PIN R4 [get_ports { fabEthTxP[2][3] }]
set_property PACKAGE_PIN R3 [get_ports { fabEthTxN[2][3] }]
set_property PACKAGE_PIN P2 [get_ports { fabEthRxP[2][3] }]
set_property PACKAGE_PIN P1 [get_ports { fabEthRxN[2][3] }]

# ATCA Backplane: FABRIC ETH[3]

set_property PACKAGE_PIN AH6 [get_ports { fabEthTxP[3][0] }]
set_property PACKAGE_PIN AH5 [get_ports { fabEthTxN[3][0] }]
set_property PACKAGE_PIN AH2 [get_ports { fabEthRxP[3][0] }]
set_property PACKAGE_PIN AH1 [get_ports { fabEthRxN[3][0] }]

set_property PACKAGE_PIN AG4 [get_ports { fabEthTxP[3][1] }]
set_property PACKAGE_PIN AG3 [get_ports { fabEthTxN[3][1] }]
set_property PACKAGE_PIN AF2 [get_ports { fabEthRxP[3][1] }]
set_property PACKAGE_PIN AF1 [get_ports { fabEthRxN[3][1] }]

set_property PACKAGE_PIN AE4 [get_ports { fabEthTxP[3][2] }]
set_property PACKAGE_PIN AE3 [get_ports { fabEthTxN[3][2] }]
set_property PACKAGE_PIN AD2 [get_ports { fabEthRxP[3][2] }]
set_property PACKAGE_PIN AD1 [get_ports { fabEthRxN[3][2] }]

set_property PACKAGE_PIN AC4 [get_ports { fabEthTxP[3][3] }]
set_property PACKAGE_PIN AC3 [get_ports { fabEthTxN[3][3] }]
set_property PACKAGE_PIN AB2 [get_ports { fabEthRxP[3][3] }]
set_property PACKAGE_PIN AB1 [get_ports { fabEthRxN[3][3] }]

# ATCA Backplane: FABRIC ETH[4]

set_property PACKAGE_PIN AN4 [get_ports { fabEthTxP[4][0] }]
set_property PACKAGE_PIN AN3 [get_ports { fabEthTxN[4][0] }]
set_property PACKAGE_PIN AP2 [get_ports { fabEthRxP[4][0] }]
set_property PACKAGE_PIN AP1 [get_ports { fabEthRxN[4][0] }]

set_property PACKAGE_PIN AM6 [get_ports { fabEthTxP[4][1] }]
set_property PACKAGE_PIN AM5 [get_ports { fabEthTxN[4][1] }]
set_property PACKAGE_PIN AM2 [get_ports { fabEthRxP[4][1] }]
set_property PACKAGE_PIN AM1 [get_ports { fabEthRxN[4][1] }]

set_property PACKAGE_PIN AL4 [get_ports { fabEthTxP[4][2] }]
set_property PACKAGE_PIN AL3 [get_ports { fabEthTxN[4][2] }]
set_property PACKAGE_PIN AK2 [get_ports { fabEthRxP[4][2] }]
set_property PACKAGE_PIN AK1 [get_ports { fabEthRxN[4][2] }]

set_property PACKAGE_PIN AK6 [get_ports { fabEthTxP[4][3] }]
set_property PACKAGE_PIN AK5 [get_ports { fabEthTxN[4][3] }]
set_property PACKAGE_PIN AJ4 [get_ports { fabEthRxP[4][3] }]
set_property PACKAGE_PIN AJ3 [get_ports { fabEthRxN[4][3] }]

# IMPC Ports
set_property -dict { PACKAGE_PIN AK8 IOSTANDARD LVCMOS33 } [get_ports { ipmcScl }]
set_property -dict { PACKAGE_PIN AL8 IOSTANDARD LVCMOS33 } [get_ports { ipmcSda }]
