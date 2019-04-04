-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggEthFp.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Front Panel LVDS SGMII Ports 
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS ATCA LINK AGG DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https:--confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
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
use work.GigEthPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggEthFp is
   generic (
      TPD_G           : time                := 1 ns;
      SIMULATION_G    : boolean             := false;
      PAUSE_EN_G      : boolean             := true;
      PAUSE_512BITS_G : positive            := 8;
      EN_AXI_REG_G    : boolean             := false;
      AXIS_CONFIG_G   : AxiStreamConfigType := EMAC_AXIS_CONFIG_C);
   port (
      ref156Clk       : in  sl;
      ref156Rst       : in  sl;
      -- Local Configurations/status
      localMac        : in  slv(47 downto 0);  --  big-Endian configuration 
      ethLinkUp       : out sl;
      -- Interface to Ethernet Media Access Controller (MAC)
      axilClk         : in  sl;
      axilRst         : in  sl;
      obMacMaster     : out AxiStreamMasterType;
      obMacSlave      : in  AxiStreamSlaveType;
      ibMacMaster     : in  AxiStreamMasterType;
      ibMacSlave      : out AxiStreamSlaveType;
      -- Slave AXI-Lite Interface 
      axilReadMaster  : in  AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Asynchronous LVDS SGMII Ports
      fpEthTxP        : out sl;
      fpEthTxN        : out sl;
      fpEthRxP        : in  sl;
      fpEthRxN        : in  sl);
end AtlasAtcaLinkAggEthFp;

architecture mapping of AtlasAtcaLinkAggEthFp is

   component AtlasAtcaLinkAggEthFpCore
      port (
         clk125m                : in  std_logic;
         sgmii_clk_r_0          : out std_logic;
         sgmii_clk_f_0          : out std_logic;
         sgmii_clk_en_0         : out std_logic;
         clk312                 : in  std_logic;
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
         tx_bsc_rst             : in  std_logic;
         rx_bsc_rst             : in  std_logic;
         rx_bs_rst              : in  std_logic;
         tx_bs_rst              : in  std_logic;
         tx_rst_dly             : in  std_logic;
         rx_rst_dly             : in  std_logic;
         riu_clk                : in  std_logic;
         riu_wr_en              : in  std_logic;
         tx_pll_clk             : in  std_logic;
         rx_pll_clk             : in  std_logic;
         tx_rdclk               : in  std_logic;
         tx_bsc_en_vtc          : in  std_logic;
         tx_bs_en_vtc           : in  std_logic;
         rx_bsc_en_vtc          : in  std_logic;
         rx_bs_en_vtc           : in  std_logic;
         tx_dly_rdy             : out std_logic;
         rx_dly_rdy             : out std_logic;
         tx_vtc_rdy             : out std_logic;
         rx_vtc_rdy             : out std_logic;
         riu_addr               : in  std_logic_vector(5 downto 0);
         riu_wr_data            : in  std_logic_vector(15 downto 0);
         riu_nibble_sel         : in  std_logic_vector(1 downto 0);
         rx_btval               : in  std_logic_vector(8 downto 0);
         riu_prsnt              : out std_logic;
         riu_valid              : out std_logic;
         riu_rd_data            : out std_logic_vector(15 downto 0));
   end component;

   signal tx_bsc_rst     : std_logic;
   signal rx_bsc_rst     : std_logic;
   signal rx_bs_rst      : std_logic;
   signal tx_bs_rst      : std_logic;
   signal tx_rst_dly     : std_logic;
   signal rx_rst_dly     : std_logic;
   signal riu_clk        : std_logic;
   signal riu_wr_en      : std_logic;
   signal tx_pll_clk     : std_logic;
   signal rx_pll_clk     : std_logic;
   signal tx_rdclk       : std_logic;
   signal tx_bsc_en_vtc  : std_logic;
   signal tx_bs_en_vtc   : std_logic;
   signal rx_bsc_en_vtc  : std_logic;
   signal rx_bs_en_vtc   : std_logic;
   signal tx_dly_rdy     : std_logic;
   signal rx_dly_rdy     : std_logic;
   signal tx_vtc_rdy     : std_logic;
   signal rx_vtc_rdy     : std_logic;
   signal riu_addr       : std_logic_vector(5 downto 0);
   signal riu_wr_data    : std_logic_vector(15 downto 0);
   signal riu_nibble_sel : std_logic_vector(1 downto 0);
   signal rx_btval       : std_logic_vector(8 downto 0);
   signal riu_prsnt      : std_logic;
   signal riu_valid      : std_logic;
   signal riu_rd_data    : std_logic_vector(15 downto 0);
   signal logic_reset    : std_logic;

   signal gmiiTxClk : sl;
   signal gmiiTxd   : slv(7 downto 0);
   signal gmiiTxEn  : sl;
   signal gmiiTxEr  : sl;

   signal gmiiRxClk : sl;
   signal gmiiRxd   : slv(7 downto 0);
   signal gmiiRxDv  : sl;
   signal gmiiRxEr  : sl;

   signal sysClk312 : sl;
   signal sysClk125 : sl;
   signal sysRst125 : sl;


   signal tx_locked        : sl;
   signal rx_locked        : sl;
   signal Tx_Logic_Rst_int : sl;
   signal Rx_Logic_Rst_int : sl;



   signal config : GigEthConfigType;
   signal status : GigEthStatusType;

begin

   -----------
   -- Clocking
   -----------
   U_CLK : entity work.AtlasAtcaLinkAggEthFpClk
      port map (
         ClockIn        => ref156Clk,
         ResetIn        => ref156Rst,
         Tx_Dly_Rdy     => tx_dly_rdy,
         Tx_Vtc_Rdy     => tx_vtc_rdy,
         Rx_Dly_Rdy     => rx_dly_rdy,
         Rx_Vtc_Rdy     => rx_vtc_rdy,
         Tx_Bsc_EnVtc   => tx_bsc_en_vtc,
         Tx_Bs_EnVtc    => tx_bs_en_vtc,
         Rx_Bsc_EnVtc   => rx_bsc_en_vtc,
         Rx_Bs_EnVtc    => rx_bs_en_vtc,
         Tx_SysClk      => tx_rdclk,    -- 312.5MHz
         Tx_WrClk       => sysClk125,   -- 125 MHz
         Tx_ClkOutPhy   => tx_pll_clk,  -- 1250 MHz
         Rx_SysClk      => sysClk312,   -- 312.5 MHz
         Rx_RiuClk      => riu_clk,     -- 208 MHz
         Rx_ClkOutPhy   => rx_pll_clk,  -- 625 MHz
         Tx_Locked      => tx_locked,
         Tx_Bs_RstDly   => tx_rst_dly,
         Tx_Bs_Rst      => tx_bs_rst,
         Tx_Bsc_Rst     => tx_bsc_rst,
         Tx_LogicRst    => Tx_Logic_Rst_int,
         Rx_Locked      => rx_locked,
         Rx_Bs_RstDly   => rx_rst_dly,
         Rx_Bs_Rst      => rx_bs_rst,
         Rx_Bsc_Rst     => rx_bsc_rst,
         Rx_LogicRst    => Rx_Logic_Rst_int,
         Riu_Addr       => riu_addr,
         Riu_WrData     => riu_wr_data,
         Riu_RdData_0   => riu_rd_data,
         Riu_Valid_0    => riu_valid,
         Rx_BtVal_0     => rx_btval,
         Riu_Prsnt_0    => riu_prsnt,
         Riu_Wr_En      => riu_wr_en,
         Riu_Nibble_Sel => riu_nibble_sel,
         Riu_RdData_3   => (others => '0'),
         Riu_Valid_3    => '0',
         Riu_Prsnt_3    => '0',
         Riu_RdData_2   => (others => '0'),
         Riu_Valid_2    => '0',
         Riu_Prsnt_2    => '0',
         Riu_RdData_1   => (others => '0'),
         Riu_Valid_1    => '0',
         Riu_Prsnt_1    => '0',
         Rx_BtVal_3     => open,
         Rx_BtVal_2     => open,
         Rx_BtVal_1     => open);

   logic_reset <= Tx_Logic_Rst_int or Rx_Logic_Rst_int;

   U_RST : entity work.RstSync
      generic map (
         TPD_G => TPD_G)
      port map (
         clk      => sysClk125,
         asyncRst => ref156Rst,
         syncRst  => sysRst125);

   ------------
   -- SGMII PHY
   ------------
   U_PHY : AtlasAtcaLinkAggEthFpCore
      port map (
         clk312                 => sysClk312,
         clk125m                => sysClk125,
         reset                  => sysRst125,
         tx_bsc_rst             => tx_bsc_rst,
         rx_bsc_rst             => rx_bsc_rst,
         tx_bs_rst              => tx_bs_rst,
         rx_bs_rst              => rx_bs_rst,
         tx_rst_dly             => tx_rst_dly,
         rx_rst_dly             => rx_rst_dly,
         tx_bsc_en_vtc          => tx_bsc_en_vtc,
         rx_bsc_en_vtc          => rx_bsc_en_vtc,
         tx_bs_en_vtc           => tx_bs_en_vtc,
         rx_bs_en_vtc           => rx_bs_en_vtc,
         riu_clk                => riu_clk,
         riu_addr               => riu_addr,
         riu_wr_data            => riu_wr_data,
         riu_wr_en              => riu_wr_en,
         riu_nibble_sel         => riu_nibble_sel,
         riu_rd_data            => riu_rd_data,
         riu_valid              => riu_valid,
         rx_btval               => rx_btval,
         riu_prsnt              => riu_prsnt,
         tx_pll_clk             => tx_pll_clk,
         rx_pll_clk             => rx_pll_clk,
         tx_dly_rdy             => tx_Dly_Rdy,
         tx_vtc_rdy             => tx_Vtc_Rdy,
         rx_dly_rdy             => rx_Dly_Rdy,
         rx_vtc_rdy             => rx_Vtc_Rdy,
         tx_rdclk               => tx_rdclk,
         txp_0                  => fpEthTxP,
         txn_0                  => fpEthTxN,
         rxp_0                  => fpEthRxP,
         rxn_0                  => fpEthRxP,
         gmii_txd_0             => gmiiTxd,
         gmii_tx_en_0           => gmiiTxEn,
         gmii_tx_er_0           => gmiiTxEr,
         gmii_rxd_0             => gmiiRxd,
         gmii_rx_dv_0           => gmiiRxDv,
         gmii_rx_er_0           => gmiiRxEr,
         gmii_isolate_0         => open,
         sgmii_clk_r_0          => open,
         sgmii_clk_f_0          => open,
         sgmii_clk_en_0         => open,
         speed_is_10_100_0      => '0',
         speed_is_100_0         => '0',
         status_vector_0        => status.coreStatus,  -- Core status.      
         configuration_vector_0 => config.coreConfig,
         signal_detect_0        => '1');

   status.phyReady <= status.coreStatus(1);
   ethLinkUp       <= status.phyReady;

   --------------------
   -- Ethernet MAC core
   --------------------
   U_MAC : entity work.EthMacTop
      generic map (
         TPD_G           => TPD_G,
         PAUSE_EN_G      => PAUSE_EN_G,
         PAUSE_512BITS_G => PAUSE_512BITS_G,
         PHY_TYPE_G      => "GMII",
         PRIM_CONFIG_G   => EMAC_AXIS_CONFIG_C)
      port map (
         -- Primary Interface
         primClk         => axilClk,
         primRst         => axilRst,
         ibMacPrimMaster => ibMacMaster,
         ibMacPrimSlave  => ibMacSlave,
         obMacPrimMaster => obMacMaster,
         obMacPrimSlave  => obMacSlave,
         -- Ethernet Interface
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

   --------------------------------     
   -- Configuration/Status Register   
   --------------------------------     
   U_GigEthReg : entity work.GigEthReg
      generic map (
         TPD_G        => TPD_G,
         EN_AXI_REG_G => EN_AXI_REG_G)
      port map (
         -- Local Configurations
         localMac       => localMac,
         -- Clocks and resets
         clk            => sysClk125,
         rst            => sysRst125,
         -- AXI-Lite Register Interface
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave,
         -- Configuration and Status Interface
         config         => config,
         status         => status);

end mapping;
