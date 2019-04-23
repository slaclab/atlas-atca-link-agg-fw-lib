-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggEthLvds.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for Marvell 88E1111 PHY + LVDS SGMII
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
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;
use work.GigEthPkg.all;

entity AtlasAtcaLinkAggEthLvds is
   generic (
      TPD_G             : time                  := 1 ns;
      STABLE_CLK_FREQ_G : real                  := 156.25E+6;
      PHY_G             : natural range 0 to 31 := 7;
      PAUSE_EN_G        : boolean               := true;
      PAUSE_512BITS_G   : positive              := 8;
      AXIS_CONFIG_G     : AxiStreamConfigType   := EMAC_AXIS_CONFIG_C);
   port (
      -- clock and reset
      extRst      : in    sl;                -- active high
      stableClk   : in    sl;                -- Stable clock reference
      -- Local Configurations/status
      localMac    : in    slv(47 downto 0);  --  big-Endian configuration   
      linkUp      : out   sl;
      -- Interface to Ethernet Media Access Controller (MAC)
      macClk      : in    sl;
      macRst      : in    sl;
      obMacMaster : out   AxiStreamMasterType;
      obMacSlave  : in    AxiStreamSlaveType;
      ibMacMaster : in    AxiStreamMasterType;
      ibMacSlave  : out   AxiStreamSlaveType;
      -- ETH external PHY Ports
      phyClkP     : in    sl;                -- 625.0 MHz
      phyClkN     : in    sl;
      phyMdc      : out   sl;
      phyMdio     : inout sl;
      phyRstN     : out   sl;                -- active low
      phyIrqN     : in    sl;                -- active low      
      -- LVDS SGMII Ports
      sgmiiRxP    : in    sl;
      sgmiiRxN    : in    sl;
      sgmiiTxP    : out   sl;
      sgmiiTxN    : out   sl);
end entity AtlasAtcaLinkAggEthLvds;

architecture mapping of AtlasAtcaLinkAggEthLvds is

   component LvdsSgmiiEthPhy
      port (
         sgmii_clk_r_0          : out std_logic;
         sgmii_clk_f_0          : out std_logic;
         sgmii_clk_en_0         : out std_logic;
         clk125_out             : out std_logic;
         clk312_out             : out std_logic;
         rst_125_out            : out std_logic;
         refclk625_n            : in  std_logic;
         refclk625_p            : in  std_logic;
         speed_is_10_100_0      : in  std_logic;
         speed_is_100_0         : in  std_logic;
         reset                  : in  std_logic;
         txn_0                  : out std_logic;
         rxn_0                  : in  std_logic;
         gmii_txd_0             : in  std_logic_vector(7 downto 0);
         gmii_rxd_0             : out std_logic_vector(7 downto 0);
         txp_0                  : out std_logic;
         gmii_rx_dv_0           : out std_logic;
         gmii_rx_er_0           : out std_logic;
         gmii_isolate_0         : out std_logic;
         rxp_0                  : in  std_logic;
         signal_detect_0        : in  std_logic;
         gmii_tx_en_0           : in  std_logic;
         gmii_tx_er_0           : in  std_logic;
         configuration_vector_0 : in  std_logic_vector(4 downto 0);
         status_vector_0        : out std_logic_vector(15 downto 0);
         tx_dly_rdy_1           : in  std_logic;
         rx_dly_rdy_1           : in  std_logic;
         tx_vtc_rdy_1           : in  std_logic;
         rx_vtc_rdy_1           : in  std_logic;
         tx_dly_rdy_2           : in  std_logic;
         rx_dly_rdy_2           : in  std_logic;
         tx_vtc_rdy_2           : in  std_logic;
         rx_vtc_rdy_2           : in  std_logic;
         tx_dly_rdy_3           : in  std_logic;
         rx_dly_rdy_3           : in  std_logic;
         tx_vtc_rdy_3           : in  std_logic;
         rx_vtc_rdy_3           : in  std_logic;
         tx_logic_reset         : out std_logic;
         rx_logic_reset         : out std_logic;
         rx_locked              : out std_logic;
         tx_locked              : out std_logic;
         tx_bsc_rst_out         : out std_logic;
         rx_bsc_rst_out         : out std_logic;
         tx_bs_rst_out          : out std_logic;
         rx_bs_rst_out          : out std_logic;
         tx_rst_dly_out         : out std_logic;
         rx_rst_dly_out         : out std_logic;
         tx_bsc_en_vtc_out      : out std_logic;
         rx_bsc_en_vtc_out      : out std_logic;
         tx_bs_en_vtc_out       : out std_logic;
         rx_bs_en_vtc_out       : out std_logic;
         riu_clk_out            : out std_logic;
         riu_wr_en_out          : out std_logic;
         tx_pll_clk_out         : out std_logic;
         rx_pll_clk_out         : out std_logic;
         tx_rdclk_out           : out std_logic;
         riu_addr_out           : out std_logic_vector(5 downto 0);
         riu_wr_data_out        : out std_logic_vector(15 downto 0);
         riu_nibble_sel_out     : out std_logic_vector(1 downto 0);
         rx_btval_1             : out std_logic_vector(8 downto 0);
         rx_btval_2             : out std_logic_vector(8 downto 0);
         rx_btval_3             : out std_logic_vector(8 downto 0);
         riu_valid_3            : in  std_logic;
         riu_valid_2            : in  std_logic;
         riu_valid_1            : in  std_logic;
         riu_prsnt_1            : in  std_logic;
         riu_prsnt_2            : in  std_logic;
         riu_prsnt_3            : in  std_logic;
         riu_rddata_3           : in  std_logic_vector(15 downto 0);
         riu_rddata_1           : in  std_logic_vector(15 downto 0);
         riu_rddata_2           : in  std_logic_vector(15 downto 0)
         );
   end component;

   signal phyClock : sl;
   signal phyReset : sl;

   signal phyInitRst : sl;
   signal phyIrq     : sl;
   signal phyMdi     : sl;
   signal phyMdo     : sl := '1';

   signal extPhyRstN  : sl := '0';
   signal extPhyReady : sl := '0';

   signal sp10_100 : sl := '0';
   signal sp100    : sl := '0';
   signal initDone : sl := '0';

   signal config : GigEthConfigType;
   signal status : GigEthStatusType;

   signal sysClk125 : sl;
   signal sysRst125 : sl;
   signal ethClkEn  : sl;
   signal phyReady  : sl;
   
   signal gmiiTxClk : sl;
   signal gmiiTxd   : slv(7 downto 0);
   signal gmiiTxEn  : sl;
   signal gmiiTxEr  : sl;

   signal gmiiRxClk : sl;
   signal gmiiRxd   : slv(7 downto 0);
   signal gmiiRxDv  : sl;
   signal gmiiRxEr  : sl;   

begin

   -- Tri-state driver for phyMdio
   phyMdio <= 'Z' when phyMdo = '1' else '0';

   -- Reset line of the external phy
   phyRstN <= extPhyRstN;

   --------------------------------------------------------------------------
   -- We must hold reset for >10ms and then wait >5ms until we may talk
   -- to it (we actually wait also >10ms) which is indicated by 'extPhyReady'
   --------------------------------------------------------------------------
   U_PwrUpRst0 : entity work.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '0',
         DURATION_G     => getTimeRatio(STABLE_CLK_FREQ_G, 100.0))  -- 10 ms reset
      port map (
         arst   => extRst,
         clk    => stableClk,
         rstOut => extPhyRstN);

   U_PwrUpRst1 : entity work.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '0',
         DURATION_G     => getTimeRatio(STABLE_CLK_FREQ_G, 100.0))  -- 10 ms reset
      port map (
         arst   => extPhyRstN,
         clk    => stableClk,
         rstOut => extPhyReady);

   ----------------------------------------------------------------------
   -- The MDIO controller which talks to the external PHY must be held
   -- in reset until extPhyReady; it works in a different clock domain...
   ----------------------------------------------------------------------
   U_PhyInitRstSync : entity work.RstSync
      generic map (
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => phyClock,
         asyncRst => extPhyReady,
         syncRst  => phyInitRst);

   -----------------------------------------------------------------------
   -- The SaltCore does not support auto-negotiation on the SGMII link
   -- (mac<->phy) - however, the Marvell PHY (by default) assumes it does.
   -- We need to disable auto-negotiation in the PHY on the SGMII side
   -- and handle link changes (aneg still enabled on copper) flagged
   -- by the PHY...
   -----------------------------------------------------------------------
   U_PhyCtrl : entity work.Sgmii88E1111Mdio
      generic map (
         TPD_G => TPD_G,
         PHY_G => PHY_G,
         DIV_G => 100)
      port map (
         clk             => phyClock,
         rst             => phyInitRst,
         initDone        => initDone,
         speed_is_10_100 => sp10_100,
         speed_is_100    => sp100,
         linkIsUp        => linkUp,
         mdi             => phyMdi,
         mdc             => phyMdc,
         mdo             => phyMdo,
         linkIrq         => phyIrq);

   ----------------------------------------------------
   -- synchronize MDI and IRQ signals into 'clk' domain
   ----------------------------------------------------
   U_SyncMdi : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => phyClock,
         dataIn  => phyMdio,
         dataOut => phyMdi);

   U_SyncIrq : entity work.Synchronizer
      generic map (
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '0',
         INIT_G         => "11")
      port map (
         clk     => phyClock,
         dataIn  => phyIrqN,
         dataOut => phyIrq);

   --------------------
   -- Ethernet MAC core
   --------------------
   U_MAC : entity work.EthMacTop
      generic map (
         TPD_G           => TPD_G,
         PAUSE_EN_G      => PAUSE_EN_G,
         PAUSE_512BITS_G => PAUSE_512BITS_G,
         PHY_TYPE_G      => "GMII",
         PRIM_CONFIG_G   => AXIS_CONFIG_G)
      port map (
         -- Primary Interface
         primClk         => macClk,
         primRst         => macRst,
         ibMacPrimMaster => ibMacMaster,
         ibMacPrimSlave  => ibMacSlave,
         obMacPrimMaster => obMacMaster,
         obMacPrimSlave  => obMacSlave,
         -- Ethernet Interface
         ethClkEn        => ethClkEn,
         ethClk          => sysClk125,
         ethRst          => sysRst125,
         ethConfig       => config.macConfig,
         ethStatus       => status.macStatus,
         phyReady        => status.phyReady,
         -- GMII PHY Interface
         gmiiRxDv        => gmiiRxDv,
         gmiiRxEr        => gmiiRxEr,
         gmiiRxd         => gmiiRxd,
         gmiiTxEn        => gmiiTxEn,
         gmiiTxEr        => gmiiTxEr,
         gmiiTxd         => gmiiTxd);

   ---------------------
   -- LVDS SGMII ETH PHY
   ---------------------
   U_LVDS_PHY : LvdsSgmiiEthPhy
      port map (
         sgmii_clk_r_0          => open,
         sgmii_clk_f_0          => open,
         sgmii_clk_en_0         => ethClkEn,
         clk125_out             => sysClk125,
         clk312_out             => open,
         rst_125_out            => sysRst125,
         refclk625_n            => phyClkN,
         refclk625_p            => phyClkP,
         speed_is_10_100_0      => sp10_100,
         speed_is_100_0         => sp100,
         reset                  => phyInitRst,
         txn_0                  => sgmiiTxN,
         rxn_0                  => sgmiiRxN,
         gmii_txd_0             => gmiiTxd,
         gmii_rxd_0             => gmiiRxd,
         txp_0                  => sgmiiTxP,
         gmii_rx_dv_0           => gmiiRxDv,
         gmii_rx_er_0           => gmiiRxEr,
         gmii_isolate_0         => open,
         rxp_0                  => sgmiiRxP,
         signal_detect_0        => '1',
         gmii_tx_en_0           => gmiiTxEn,
         gmii_tx_er_0           => gmiiTxEr,
         configuration_vector_0 => config.coreConfig,
         status_vector_0        => status.coreStatus,
         tx_dly_rdy_1           => '1',
         rx_dly_rdy_1           => '1',
         tx_vtc_rdy_1           => '1',
         rx_vtc_rdy_1           => '1',
         tx_dly_rdy_2           => '1',
         rx_dly_rdy_2           => '1',
         tx_vtc_rdy_2           => '1',
         rx_vtc_rdy_2           => '1',
         tx_dly_rdy_3           => '1',
         rx_dly_rdy_3           => '1',
         tx_vtc_rdy_3           => '1',
         rx_vtc_rdy_3           => '1',
         tx_logic_reset         => open,
         rx_logic_reset         => open,
         rx_locked              => open,
         tx_locked              => open,
         tx_bsc_rst_out         => open,
         rx_bsc_rst_out         => open,
         tx_bs_rst_out          => open,
         rx_bs_rst_out          => open,
         tx_rst_dly_out         => open,
         rx_rst_dly_out         => open,
         tx_bsc_en_vtc_out      => open,
         rx_bsc_en_vtc_out      => open,
         tx_bs_en_vtc_out       => open,
         rx_bs_en_vtc_out       => open,
         riu_clk_out            => open,
         riu_wr_en_out          => open,
         tx_pll_clk_out         => open,
         rx_pll_clk_out         => open,
         tx_rdclk_out           => open,
         riu_addr_out           => open,
         riu_wr_data_out        => open,
         riu_nibble_sel_out     => open,
         rx_btval_1             => open,
         rx_btval_2             => open,
         rx_btval_3             => open,
         riu_valid_3            => '0',
         riu_valid_2            => '0',
         riu_valid_1            => '0',
         riu_prsnt_1            => '0',
         riu_prsnt_2            => '0',
         riu_prsnt_3            => '0',
         riu_rddata_3           => (others => '0'),
         riu_rddata_1           => (others => '0'),
         riu_rddata_2           => (others => '0'));

   status.phyReady <= status.coreStatus(0);
   phyReady        <= status.phyReady;

   --------------------------------
   -- Configuration/Status Register
   --------------------------------
   U_GigEthReg : entity work.GigEthReg
      generic map (
         TPD_G        => TPD_G,
         EN_AXI_REG_G => false)
      port map (
         -- Local Configurations
         localMac       => localMac,
         -- Clocks and resets
         clk            => sysClk125,
         rst            => sysRst125,
         -- AXI-Lite Register Interface
         axiReadMaster  => AXI_LITE_READ_MASTER_INIT_C,
         axiReadSlave   => open,
         axiWriteMaster => AXI_LITE_WRITE_MASTER_INIT_C,
         axiWriteSlave  => open,
         -- Configuration and Status Interface
         config         => config,
         status         => status);

end mapping;
