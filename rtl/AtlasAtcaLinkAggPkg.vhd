-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggPkg.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: ATLAS ATCA Link Aggregator VHDL package
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS ATCA LINK AGG DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

package AtlasAtcaLinkAggPkg is

   constant XIL_DEVICE_C : string := "ULTRASCALE_PLUS";

   constant NUM_ETH_C         : positive := 6;  -- FAB_ETH[4:1], BASE_ETH[1], FP_ETH
   constant AXIL_CLK_FREQ_C   : real     := 156.25E+6;  -- In units of Hz
   constant AXIL_CLK_PERIOD_C : real     := (1.0/AXIL_CLK_FREQ_C);  -- In units of seconds      

   constant APP_AXIL_BASE_ADDR_C : slv(31 downto 0) := x"80000000";

   ---------------------------------
   -- Ethernet stream configurations
   ---------------------------------
   constant APP_AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(8, TKEEP_COMP_C, TUSER_FIRST_LAST_C, 8);  -- Use 8 tDest bits

   type FabEthConfigType is (
      -- ETH_40G_4LANE,                 -- 40GBASE-KR4
      ETH_10G_1LANE,                    -- 10GBASE-KR
      ETH_10G_4LANE,                    -- 10GBASE-KX4 (A.K.A. "XAUI")
      ETH_1G_1LANE);                    -- 1000BASE-KX

   type EthConfigType is record
      enable      : boolean;            -- Enable the ETH port to be built
      enDhcp      : boolean;            -- Enable DHCP support
      enXvc       : boolean;  -- Enable the Xilinx XVC debug to be built
      enSrp       : boolean;            -- Enable SRPv3 to be built
      fabConfig   : FabEthConfigType;  -- Sets the type of configuration for the fabric channel (ignored for BASE and FP ETH ports)
      -- Streaming Data Server Configurations
      numSrvData  : natural range 0 to 8;  -- sets the number of server data RSSI channels
      enSrvDataTx : boolean;  -- Option to enable TX (disable saves resources)
      enSrvDataRx : boolean;  -- Option to enable RX (disable saves resources)
      -- Streaming Data Client Configurations
      numCltData  : natural range 0 to 8;  -- sets the number of client data RSSI channels
      enCltDataTx : boolean;  -- Option to enable TX (disable saves resources)
      enCltDataRx : boolean;  -- Option to enable RX (disable saves resources)      
      enDataJumbo : boolean;  -- Enable Jumbo frames support for the streaming data path
   end record;
   constant ETH_CONFIG_INIT_C : EthConfigType := (
      enable      => true,
      enDhcp      => true,
      enXvc       => false,
      enSrp       => true,
      fabConfig   => ETH_1G_1LANE,
      -- Streaming Data Server Configurations
      numSrvData  => 0,
      enSrvDataTx => true,
      enSrvDataRx => true,
      -- Streaming Data Client Configurations
      numCltData  => 0,
      enCltDataTx => true,
      enCltDataRx => true,
      enDataJumbo => false);
   type EthConfigArray is array (NUM_ETH_C-1 downto 0) of EthConfigType;  -- ETH_CONFIG_G[3:0] = FAB_ETH[4:1], ETH_CONFIG_G[4] = BASE_ETH, ETH_CONFIG_G[5] = FP_ETH

   ---------------------------------------------------
   -- BSI: Configurations, Constants and Records Types
   ---------------------------------------------------
   type BsiBusType is record
      slotNumber : slv(7 downto 0);
      crateId    : slv(15 downto 0);
      macAddress : Slv48Array(NUM_ETH_C-1 downto 0);  --  big-Endian format 
   end record;
   constant BSI_BUS_INIT_C : BsiBusType := (
      slotNumber => x"00",
      crateId    => x"0000",
      macAddress => (others => (others => '0')));

end package AtlasAtcaLinkAggPkg;
