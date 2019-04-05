-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggEthFab.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Front Panel LVDS SGMII Ports 
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.EthMacPkg.all;
use work.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggEthFab is
   generic (
      TPD_G            : time    := 1 ns;
      SIMULATION_G     : boolean := false;
      FAB_ETH_CONFIG_G : FabEthConfigType);
   port (
      -- Clocks and Resets
      axilClk           : in    sl;
      axilRst           : in    sl;
      eth125Clk         : in    sl;
      eth125Rst         : in    sl;
      eth62Clk          : in    sl;
      eth62Rst          : in    sl;
      -- Local Configurations/status
      localMac     : in  slv(47 downto 0);  --  big-Endian configuration 
      ethLinkUp    : out sl;
      -- Interface to Ethernet Media Access Controller (MAC)
      obMacMaster  : out AxiStreamMasterType;
      obMacSlave   : in  AxiStreamSlaveType;
      ibMacMaster  : in  AxiStreamMasterType;
      ibMacSlave   : out AxiStreamSlaveType;
      -- ATCA Backplane: FABRIC ETH
      fabEthRefClk : in  sl;
      fabEthTxP    : out slv(3 downto 0);
      fabEthTxN    : out slv(3 downto 0);
      fabEthRxP    : in  slv(3 downto 0);
      fabEthRxN    : in  slv(3 downto 0));
end AtlasAtcaLinkAggEthFab;

architecture mapping of AtlasAtcaLinkAggEthFab is

begin

   --------------
   -- 1000BASE-KX
   --------------
   GEN_ETH_1Gx1 : if (FAB_ETH_CONFIG_G = ETH_1G_1LANE) generate

      U_Eth : entity work.GigEthGthUltraScaleWrapper
         generic map (
            TPD_G         => TPD_G,
            EXT_PLL_G     => true,
            -- DMA/MAC Configurations
            NUM_LANE_G    => 1,
            -- AXI Streaming Configurations
            AXIS_CONFIG_G => (others => EMAC_AXIS_CONFIG_C))
         port map (
            -- Local Configurations
            localMac(0)     => localMac,
            -- Streaming DMA Interface 
            dmaClk(0)       => axilClk,
            dmaRst(0)       => axilRst,
            dmaIbMasters(0) => obMacMaster,
            dmaIbSlaves(0)  => obMacSlave,
            dmaObMasters(0) => ibMacMaster,
            dmaObSlaves(0)  => ibMacSlave,
            -- Misc. Signals
            extRst          => axilRst,
            phyReady(0)     => ethLinkUp,
            -- External PLL Interface
            extPll125Clk    => eth125Clk,
            extPll125Rst    => eth125Rst,
            extPll62Clk     => eth62Clk,
            extPll62Rst     => eth62Rst,
            -- MGT Ports
            gtTxP(0)        => fabEthTxP(0),
            gtTxN(0)        => fabEthTxN(0),
            gtRxP(0)        => fabEthRxP(0),
            gtRxN(0)        => fabEthRxN(0));

      U_TERM_GTs : entity work.Gthe4ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 3)
         port map (
            refClk => axilClk,
            gtRxP  => fabEthRxP(3 downto 1),
            gtRxN  => fabEthRxN(3 downto 1),
            gtTxP  => fabEthTxP(3 downto 1),
            gtTxN  => fabEthTxN(3 downto 1));

   end generate;

   ------------------------------
   -- 10GBASE-KX4 (A.K.A. "XAUI")
   ------------------------------
   GEN_ETH_10Gx4 : if (FAB_ETH_CONFIG_G = ETH_10G_4LANE) generate
      U_Eth : entity work.XauiGthUltraScaleWrapper
         generic map (
            TPD_G         => TPD_G,
            EN_WDT_G      => true,
            EXT_REF_G     => true,
            AXIS_CONFIG_G => EMAC_AXIS_CONFIG_C)
         port map (
            -- Local Configurations
            localMac    => localMac,
            -- Streaming DMA Interface 
            dmaClk      => axilClk,
            dmaRst      => axilRst,
            dmaIbMaster => obMacMaster,
            dmaIbSlave  => obMacSlave,
            dmaObMaster => ibMacMaster,
            dmaObSlave  => ibMacSlave,
            -- Misc. Signals
            extRst      => axilRst,
            stableClk   => axilClk,
            phyReady    => ethLinkUp,
            -- MGT Clock Port (156.25 MHz)
            gtRefClk    => fabEthRefClk,
            -- MGT Ports
            gtTxP       => fabEthTxP,
            gtTxN       => fabEthTxN,
            gtRxP       => fabEthRxP,
            gtRxN       => fabEthRxN);
   end generate;

   -------------
   -- 10GBASE-KR
   -------------
   GEN_ETH_10Gx1 : if (FAB_ETH_CONFIG_G = ETH_10G_1LANE) generate

      U_Eth : entity work.TenGigEthGthUltraScaleWrapper
         generic map (
            TPD_G             => TPD_G,
            EXT_REF_G         => true,
            -- DMA/MAC Configurations
            NUM_LANE_G        => 1,
            -- AXI Streaming Configurations
            AXIS_CONFIG_G     => (others => EMAC_AXIS_CONFIG_C))
         port map (
            -- Local Configurations
            localMac(0)     => localMac,
            -- Streaming DMA Interface 
            dmaClk(0)       => axilClk,
            dmaRst(0)       => axilRst,
            dmaIbMasters(0) => obMacMaster,
            dmaIbSlaves(0)  => obMacSlave,
            dmaObMasters(0) => ibMacMaster,
            dmaObSlaves(0)  => ibMacSlave,
            -- Misc. Signals
            extRst          => axilRst,
            phyReady(0)     => ethLinkUp,
            -- MGT Clock Port (156.25 MHz)
            gtRefClk        => fabEthRefClk,
            gtRefClkBufg    => axilClk,
            -- MGT Ports
            gtTxP(0)        => fabEthTxP(0),
            gtTxN(0)        => fabEthTxN(0),
            gtRxP(0)        => fabEthRxP(0),
            gtRxN(0)        => fabEthRxN(0));

      U_TERM_GTs : entity work.Gthe4ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 3)
         port map (
            refClk => axilClk,
            gtRxP  => fabEthRxP(3 downto 1),
            gtRxN  => fabEthRxN(3 downto 1),
            gtTxP  => fabEthTxP(3 downto 1),
            gtTxN  => fabEthTxN(3 downto 1));

   end generate;

end mapping;
