-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggEth.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Ethernet Wrapper
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.EthMacPkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggEth is
   generic (
      TPD_G            : time             := 1 ns;
      SIMULATION_G     : boolean          := false;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := (others => '0');
      ETH_CONFIG_G     : EthConfigArray   := (others => ETH_CONFIG_INIT_C));  -- ETH_CONFIG_G[3:0] = FAB_ETH[4:1], ETH_CONFIG_G[5:4] = FP_ETH[1:0]
   port (
      ----------------------------------------------
      --  Interfaces to Application (axilClk domain)
      ----------------------------------------------
      -- Clocks and Resets
      axilClk           : in    sl;
      axilRst           : in    sl;
      ref156Clk         : in    sl;
      ref156Rst         : in    sl;
      eth125Clk         : in    sl;
      eth125Rst         : in    sl;
      eth62Clk          : in    sl;
      eth62Rst          : in    sl;
      -- AXI-Lite Slave Interface
      sAxilReadMaster   : in    AxiLiteReadMasterType;
      sAxilReadSlave    : out   AxiLiteReadSlaveType;
      sAxilWriteMaster  : in    AxiLiteWriteMasterType;
      sAxilWriteSlave   : out   AxiLiteWriteSlaveType;
      -- AXI-Lite Master Interfaces
      mAxilReadMasters  : out   AxiLiteReadMasterArray(NUM_ETH_C-1 downto 0)    := (others => AXI_LITE_READ_MASTER_INIT_C);
      mAxilReadSlaves   : in    AxiLiteReadSlaveArray(NUM_ETH_C-1 downto 0);
      mAxilWriteMasters : out   AxiLiteWriteMasterArray(NUM_ETH_C-1 downto 0)   := (others => AXI_LITE_WRITE_MASTER_INIT_C);
      mAxilWriteSlaves  : in    AxiLiteWriteSlaveArray(NUM_ETH_C-1 downto 0);
      -- Server Streaming Interface (axilClk domain)
      srvIbMasters      : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvIbSlaves       : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      srvObMasters      : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvObSlaves       : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Client Streaming Interface (axilClk domain)
      cltIbMasters      : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltIbSlaves       : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      cltObMasters      : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltObSlaves       : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Local Configuration
      localMac          : in    Slv48Array(NUM_ETH_C-1 downto 0);
      localIp           : in    Slv32Array(NUM_ETH_C-1 downto 0);
      ethLinkUp         : out   slv(NUM_ETH_C-1 downto 0)                       := (others => '0');
      -------------------   
      --  Top Level Ports
      -------------------   
      -- Front Panel: ETH[1:0] SGMII Ports
      sgmiiClkP    : in  sl;
      sgmiiClkN    : in  sl;
      sgmiiRxP     : in  slv(1 downto 0);
      sgmiiRxN     : in  slv(1 downto 0);
      sgmiiTxP     : out slv(1 downto 0);
      sgmiiTxN     : out slv(1 downto 0);
      -- ATCA Backplane: FABRIC ETH[1:4]
      fabEthRefClk      : in    sl;
      fabEthTxP         : out   Slv4Array(4 downto 1);
      fabEthTxN         : out   Slv4Array(4 downto 1);
      fabEthRxP         : in    Slv4Array(4 downto 1);
      fabEthRxN         : in    Slv4Array(4 downto 1));
end AtlasAtcaLinkAggEth;

architecture mapping of AtlasAtcaLinkAggEth is

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_ETH_C-1 downto 0) := genAxiLiteConfig(NUM_ETH_C, AXIL_BASE_ADDR_G, 24, 20);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_ETH_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_ETH_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_ETH_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_ETH_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal obMacMasters : AxiStreamMasterArray(NUM_ETH_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal obMacSlaves  : AxiStreamSlaveArray(NUM_ETH_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal ibMacMasters : AxiStreamMasterArray(NUM_ETH_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal ibMacSlaves  : AxiStreamSlaveArray(NUM_ETH_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

begin

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_ETH_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => sAxilWriteMaster,
         sAxiWriteSlaves(0)  => sAxilWriteSlave,
         sAxiReadMasters(0)  => sAxilReadMaster,
         sAxiReadSlaves(0)   => sAxilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   GEN_FAB :
   for i in 3 downto 0 generate

      EN_ETH : if ETH_CONFIG_G(i).enable generate
         U_Fab : entity atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggEthFab
            generic map (
               TPD_G            => TPD_G,
               SIMULATION_G     => SIMULATION_G,
               FAB_ETH_CONFIG_G => ETH_CONFIG_G(i).fabConfig)
            port map (
               -- Clocks and Resets
               axilClk      => axilClk,
               axilRst      => axilRst,
               eth125Clk    => eth125Clk,
               eth125Rst    => eth125Rst,
               eth62Clk     => eth62Clk,
               eth62Rst     => eth62Rst,
               -- Local Configurations/status               
               localMac     => localMac(i),
               ethLinkUp    => ethLinkUp(i),
               -- MAC Interface (axilClk domain)
               obMacMaster  => obMacMasters(i),
               obMacSlave   => obMacSlaves(i),
               ibMacMaster  => ibMacMasters(i),
               ibMacSlave   => ibMacSlaves(i),
               -- ATCA Backplane: FABRIC ETH
               fabEthRefClk => fabEthRefClk,
               fabEthTxP    => fabEthTxP(i+1),
               fabEthTxN    => fabEthTxN(i+1),
               fabEthRxP    => fabEthRxP(i+1),
               fabEthRxN    => fabEthRxN(i+1));
      end generate;

      DIS_ETH : if not(ETH_CONFIG_G(i).enable) generate
         U_TERM_GTs : entity surf.Gthe4ChannelDummy
            generic map (
               TPD_G   => TPD_G,
               WIDTH_G => 4)
            port map (
               refClk => axilClk,
               gtRxP  => fabEthRxP(i+1),
               gtRxN  => fabEthRxN(i+1),
               gtTxP  => fabEthTxP(i+1),
               gtTxN  => fabEthTxN(i+1));
      end generate;

   end generate GEN_FAB;

   U_FrontPanelEth : entity atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggEthLvds
      generic map (
         TPD_G         => TPD_G,
         SGMII_EN_G(0) => ETH_CONFIG_G(4).enable,
         SGMII_EN_G(1) => ETH_CONFIG_G(5).enable,
         AXIS_CONFIG_G => EMAC_AXIS_CONFIG_C)
      port map(
         -- Local Configurations/status
         localMac(0)  => localMac(4),
         localMac(1)  => localMac(5),
         linkUp(0)    => ethLinkUp(4),
         linkUp(1)    => ethLinkUp(5),
         -- Interface to Ethernet Media Access Controller (MAC)
         macClk       => axilClk,
         macRst       => axilRst,
         obMacMasters => obMacMasters(5 downto 4),
         obMacSlaves  => obMacSlaves(5 downto 4),
         ibMacMasters => ibMacMasters(5 downto 4),
         ibMacSlaves  => ibMacSlaves(5 downto 4),
         -- Front Panel: ETH[1:0] SGMII Ports
         sgmiiClkP    => sgmiiClkP,
         sgmiiClkN    => sgmiiClkN,
         sgmiiTxP     => sgmiiTxP,
         sgmiiTxN     => sgmiiTxN,
         sgmiiRxP     => sgmiiRxP,
         sgmiiRxN     => sgmiiRxN);

   GEN_VEC :
   for i in 5 downto 0 generate
      GEN_RUDP : if ETH_CONFIG_G(i).enable generate
         U_Rudp : entity atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggRudp
            generic map (
               TPD_G            => TPD_G,
               SIMULATION_G     => SIMULATION_G,
               AXIL_BASE_ADDR_G => AXIL_CONFIG_C(i).baseAddr,
               ETH_CONFIG_G     => ETH_CONFIG_G(i))
            port map (
               -- Clocks and Resets
               axilClk          => axilClk,
               axilRst          => axilRst,
               -- AXI-Lite Slave Interface
               sAxilReadMaster  => axilReadMasters(i),
               sAxilReadSlave   => axilReadSlaves(i),
               sAxilWriteMaster => axilWriteMasters(i),
               sAxilWriteSlave  => axilWriteSlaves(i),
               -- AXI-Lite Master Interfaces
               mAxilReadMaster  => mAxilReadMasters(i),
               mAxilReadSlave   => mAxilReadSlaves(i),
               mAxilWriteMaster => mAxilWriteMasters(i),
               mAxilWriteSlave  => mAxilWriteSlaves(i),
               -- Server Streaming Interface (axilClk domain)
               srvIbMasters     => srvIbMasters(i),
               srvIbSlaves      => srvIbSlaves(i),
               srvObMasters     => srvObMasters(i),
               srvObSlaves      => srvObSlaves(i),
               -- Client Streaming Interface (axilClk domain)
               cltIbMasters     => cltIbMasters(i),
               cltIbSlaves      => cltIbSlaves(i),
               cltObMasters     => cltObMasters(i),
               cltObSlaves      => cltObSlaves(i),
               -- Interface to Ethernet Media Access Controller (MAC)
               obMacMaster      => obMacMasters(i),
               obMacSlave       => obMacSlaves(i),
               ibMacMaster      => ibMacMasters(i),
               ibMacSlave       => ibMacSlaves(i),
               -- Local Configuration
               localMac         => localMac(i),
               localIp          => localIp(i));
      end generate;
   end generate GEN_VEC;

end mapping;
