-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggEthLvds.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for LVDS SGMII
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
use work.AxiStreamPkg.all;
use work.EthMacPkg.all;
use work.GigEthPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggEthLvds is
   generic (
      TPD_G           : time                     := 1 ns;
      SGMII_EN_G      : BooleanArray(1 downto 0) := (others => true);
      PAUSE_EN_G      : boolean                  := false;
      PAUSE_512BITS_G : positive                 := 8;
      AXIS_CONFIG_G   : AxiStreamConfigType      := EMAC_AXIS_CONFIG_C);
   port (
      -- Local Configurations/status
      localMac     : in  Slv48Array(1 downto 0);  --  big-Endian configuration   
      linkUp       : out slv(1 downto 0)                  := "00";
      -- Interface to Ethernet Media Access Controller (MAC)
      macClk       : in  sl;
      macRst       : in  sl;
      obMacMasters : out AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      obMacSlaves  : in  AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
      ibMacMasters : in  AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      ibMacSlaves  : out AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
      -- Front Panel: ETH[1:0] SGMII Ports
      sgmiiClkP    : in  sl;            -- 625.0 MHz
      sgmiiClkN    : in  sl;
      sgmiiRxP     : in  slv(1 downto 0);
      sgmiiRxN     : in  slv(1 downto 0);
      sgmiiTxP     : out slv(1 downto 0);
      sgmiiTxN     : out slv(1 downto 0));
end entity AtlasAtcaLinkAggEthLvds;

architecture mapping of AtlasAtcaLinkAggEthLvds is

   component LvdsSgmiiEthPhy
      port (
         sgmii_clk_r_0          : out std_logic;
         sgmii_clk_f_0          : out std_logic;
         sgmii_clk_r_1          : out std_logic;
         sgmii_clk_f_1          : out std_logic;
         sgmii_clk_en_0         : out std_logic;
         sgmii_clk_en_1         : out std_logic;
         clk125_out             : out std_logic;
         clk312_out             : out std_logic;
         rst_125_out            : out std_logic;
         refclk625_n            : in  std_logic;
         refclk625_p            : in  std_logic;
         speed_is_10_100_0      : in  std_logic;
         speed_is_100_0         : in  std_logic;
         speed_is_10_100_1      : in  std_logic;
         speed_is_100_1         : in  std_logic;
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
         txn_1                  : out std_logic;
         rxn_1                  : in  std_logic;
         gmii_txd_1             : in  std_logic_vector(7 downto 0);
         gmii_rxd_1             : out std_logic_vector(7 downto 0);
         txp_1                  : out std_logic;
         gmii_rx_dv_1           : out std_logic;
         gmii_rx_er_1           : out std_logic;
         gmii_isolate_1         : out std_logic;
         rxp_1                  : in  std_logic;
         signal_detect_1        : in  std_logic;
         gmii_tx_en_1           : in  std_logic;
         gmii_tx_er_1           : in  std_logic;
         configuration_vector_0 : in  std_logic_vector(4 downto 0);
         configuration_vector_1 : in  std_logic_vector(4 downto 0);
         status_vector_0        : out std_logic_vector(15 downto 0);
         status_vector_1        : out std_logic_vector(15 downto 0);
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

   signal sysClk125 : sl;
   signal sysRst125 : sl;
   signal ethClkEn  : slv(1 downto 0) := (others => '1');
   signal phyReady  : slv(1 downto 0) := (others => '0');

   signal gmiiTxd  : Slv8Array(1 downto 0) := (others => x"BC");
   signal gmiiTxEn : slv(1 downto 0)       := (others => '0');
   signal gmiiTxEr : slv(1 downto 0)       := (others => '0');

   signal gmiiRxd  : Slv8Array(1 downto 0) := (others => x"BC");
   signal gmiiRxDv : slv(1 downto 0)       := (others => '0');
   signal gmiiRxEr : slv(1 downto 0)       := (others => '0');

   type GigEthConfigArray is array (natural range <>) of GigEthConfigType;
   type GigEthStatusArray is array (natural range <>) of GigEthStatusType;

   signal config : GigEthConfigArray(1 downto 0) := (others => GIG_ETH_CONFIG_INIT_C);
   signal status : GigEthStatusArray(1 downto 0);

begin

   EN_ETH : if SGMII_EN_G(0) or SGMII_EN_G(1) generate

      ---------------------
      -- LVDS SGMII ETH PHY
      ---------------------
      U_LVDS_PHY : LvdsSgmiiEthPhy
         port map (
            sgmii_clk_r_0          => open,
            sgmii_clk_f_0          => open,
            sgmii_clk_r_1          => open,
            sgmii_clk_f_1          => open,
            sgmii_clk_en_0         => ethClkEn(0),
            sgmii_clk_en_1         => ethClkEn(1),
            clk125_out             => sysClk125,
            clk312_out             => open,
            rst_125_out            => sysRst125,
            refclk625_n            => sgmiiClkN,
            refclk625_p            => sgmiiClkP,
            speed_is_10_100_0      => '0',
            speed_is_100_0         => '0',
            speed_is_10_100_1      => '0',
            speed_is_100_1         => '0',
            reset                  => macRst,
            txn_0                  => sgmiiTxN(0),
            rxn_0                  => sgmiiRxN(0),
            gmii_txd_0             => gmiiTxd(0),
            gmii_rxd_0             => gmiiRxd(0),
            txp_0                  => sgmiiTxP(0),
            gmii_rx_dv_0           => gmiiRxDv(0),
            gmii_rx_er_0           => gmiiRxEr(0),
            gmii_isolate_0         => open,
            rxp_0                  => sgmiiRxP(0),
            signal_detect_0        => '1',
            gmii_tx_en_0           => gmiiTxEn(0),
            gmii_tx_er_0           => gmiiTxEr(0),
            txn_1                  => sgmiiTxN(1),
            rxn_1                  => sgmiiRxN(1),
            gmii_txd_1             => gmiiTxd(1),
            gmii_rxd_1             => gmiiRxd(1),
            txp_1                  => sgmiiTxP(1),
            gmii_rx_dv_1           => gmiiRxDv(1),
            gmii_rx_er_1           => gmiiRxEr(1),
            gmii_isolate_1         => open,
            rxp_1                  => sgmiiRxP(1),
            signal_detect_1        => '1',
            gmii_tx_en_1           => gmiiTxEn(1),
            gmii_tx_er_1           => gmiiTxEr(1),
            configuration_vector_0 => config(0).coreConfig,
            configuration_vector_1 => config(1).coreConfig,
            status_vector_0        => status(0).coreStatus,
            status_vector_1        => status(1).coreStatus,
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

      GEN_VEC :
      for i in 1 downto 0 generate

         config(i).macConfig.macAddress <= localMac(i);

         GEN_MAC : if SGMII_EN_G(i) generate
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
                  ibMacPrimMaster => ibMacMasters(i),
                  ibMacPrimSlave  => ibMacSlaves(i),
                  obMacPrimMaster => obMacMasters(i),
                  obMacPrimSlave  => obMacSlaves(i),
                  -- Ethernet Interface
                  ethClkEn        => ethClkEn(i),
                  ethClk          => sysClk125,
                  ethRst          => sysRst125,
                  ethConfig       => config(i).macConfig,
                  ethStatus       => status(i).macStatus,
                  phyReady        => status(i).coreStatus(0),
                  -- GMII PHY Interface
                  gmiiRxDv        => gmiiRxDv(i),
                  gmiiRxEr        => gmiiRxEr(i),
                  gmiiRxd         => gmiiRxd(i),
                  gmiiTxEn        => gmiiTxEn(i),
                  gmiiTxEr        => gmiiTxEr(i),
                  gmiiTxd         => gmiiTxd(i));
         end generate;

      end generate GEN_VEC;

   end generate;

   DIS_ETH : if not(SGMII_EN_G(0)) and not(SGMII_EN_G(1)) generate

      U_Clk : IBUFDS
         port map (
            I  => sgmiiClkP,
            IB => sgmiiClkN,
            O  => open);

      GEN_VEC :
      for i in 1 downto 0 generate

         U_Rx : IBUFDS
            port map (
               I  => sgmiiRxP(i),
               IB => sgmiiRxN(i),
               O  => open);

         U_Tx : OBUFDS
            port map (
               I  => '0',
               O  => sgmiiTxP(i),
               OB => sgmiiTxN(i));

      end generate GEN_VEC;

   end generate;

end mapping;
