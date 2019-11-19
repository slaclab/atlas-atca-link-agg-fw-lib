-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggRudp.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RUDP Wrapper
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
use surf.SsiPkg.all;
use surf.EthMacPkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggRudp is
   generic (
      TPD_G            : time             := 1 ns;
      SIMULATION_G     : boolean          := false;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := (others => '0');
      ETH_CONFIG_G     : EthConfigType    := ETH_CONFIG_INIT_C);
   port (
      ----------------------------------------------
      --  Interfaces to Application (axilClk domain)
      ----------------------------------------------
      -- Clocks and Resets
      axilClk          : in  sl;
      axilRst          : in  sl;
      -- AXI-Lite Slave Interface
      sAxilReadMaster  : in  AxiLiteReadMasterType;
      sAxilReadSlave   : out AxiLiteReadSlaveType;
      sAxilWriteMaster : in  AxiLiteWriteMasterType;
      sAxilWriteSlave  : out AxiLiteWriteSlaveType;
      -- AXI-Lite Master Interfaces
      mAxilReadMaster  : out AxiLiteReadMasterType    := AXI_LITE_READ_MASTER_INIT_C;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType   := AXI_LITE_WRITE_MASTER_INIT_C;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      -- Server Streaming Interface
      srvIbMasters     : in  AxiStreamOctalMasterType := (others => AXI_STREAM_MASTER_INIT_C);
      srvIbSlaves      : out AxiStreamOctalSlaveType  := (others => AXI_STREAM_SLAVE_FORCE_C);
      srvObMasters     : out AxiStreamOctalMasterType := (others => AXI_STREAM_MASTER_INIT_C);
      srvObSlaves      : in  AxiStreamOctalSlaveType  := (others => AXI_STREAM_SLAVE_FORCE_C);
      -- Client Streaming Interface
      cltIbMasters     : in  AxiStreamOctalMasterType := (others => AXI_STREAM_MASTER_INIT_C);
      cltIbSlaves      : out AxiStreamOctalSlaveType  := (others => AXI_STREAM_SLAVE_FORCE_C);
      cltObMasters     : out AxiStreamOctalMasterType := (others => AXI_STREAM_MASTER_INIT_C);
      cltObSlaves      : in  AxiStreamOctalSlaveType  := (others => AXI_STREAM_SLAVE_FORCE_C);
      -- Interface to Ethernet Media Access Controller (MAC)
      obMacMaster      : in  AxiStreamMasterType;
      obMacSlave       : out AxiStreamSlaveType;
      ibMacMaster      : out AxiStreamMasterType;
      ibMacSlave       : in  AxiStreamSlaveType;
      -- Local Configuration
      localMac         : in  slv(47 downto 0);
      localIp          : in  slv(31 downto 0));
end AtlasAtcaLinkAggRudp;

architecture mapping of AtlasAtcaLinkAggRudp is

   constant SERVER_SIZE_C : positive := (2+ETH_CONFIG_G.numSrvData);

   constant UDP_SRV_XVC_IDX_C  : natural := 0;
   constant UDP_SRV_SRP_IDX_C  : natural := 1;
   constant UDP_SRV_DATA_IDX_C : natural := 2;

   constant SERVER_PORTS_C : PositiveArray(9 downto 0) := (
      UDP_SRV_XVC_IDX_C      => 2542,   -- Xilinx XVC 
      UDP_SRV_SRP_IDX_C      => 8193,
      (UDP_SRV_DATA_IDX_C+0) => 8200,
      (UDP_SRV_DATA_IDX_C+1) => 8201,
      (UDP_SRV_DATA_IDX_C+2) => 8202,
      (UDP_SRV_DATA_IDX_C+3) => 8203,
      (UDP_SRV_DATA_IDX_C+4) => 8204,
      (UDP_SRV_DATA_IDX_C+5) => 8205,
      (UDP_SRV_DATA_IDX_C+6) => 8206,
      (UDP_SRV_DATA_IDX_C+7) => 8207);

   constant CLIENT_EN_C   : boolean  := ite(ETH_CONFIG_G.numCltData > 0, true, false);
   constant CLIENT_SIZE_C : positive := ite(CLIENT_EN_C, ETH_CONFIG_G.numCltData, 1);

   constant UDP_CLT_DATA_IDX_C : natural := 0;

   constant CLIENT_PORTS_C : PositiveArray(7 downto 0) := (
      (UDP_CLT_DATA_IDX_C+0) => 8208,
      (UDP_CLT_DATA_IDX_C+1) => 8209,
      (UDP_CLT_DATA_IDX_C+2) => 8210,
      (UDP_CLT_DATA_IDX_C+3) => 8211,
      (UDP_CLT_DATA_IDX_C+4) => 8212,
      (UDP_CLT_DATA_IDX_C+5) => 8213,
      (UDP_CLT_DATA_IDX_C+6) => 8214,
      (UDP_CLT_DATA_IDX_C+7) => 8215);

   constant TIMEOUT_C          : real     := 1.0E-3;  -- In units of seconds   
   constant WINDOW_ADDR_SIZE_C : positive := 6;
   constant MAX_SEG_SIZE_C     : positive := 1024;
   constant SYNTH_MODE_C       : string := "xpm";
   constant MEMORY_TYPE_C      : string := "ultra";

   constant SRP_AXIS_CONFIG_C  : AxiStreamConfigArray(0 downto 0) := (others => ssiAxiStreamConfig(4));
   constant DATA_AXIS_CONFIG_C : AxiStreamConfigArray(0 downto 0) := (others => APP_AXIS_CONFIG_C);

   constant NUM_AXIL_MASTERS_C : positive := 18;

   constant UDP_INDEX_C : natural := 0;
   constant SRP_INDEX_C : natural := 1;
   constant SRV_INDEX_C : natural := 2;   -- [2:9]      
   constant CLT_INDEX_C : natural := 10;  -- [10:17]      

   function myGenAxiLiteConfig
      return AxiLiteCrossbarMasterConfigArray is
      variable retConf : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0);
   begin

      -------
      -- Init
      -------
      retConf := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 20, 12);

      -----------------------------------------------------------------
      -- Mask off the unused channel (helps with synthesis optimization
      -----------------------------------------------------------------
      if (ETH_CONFIG_G.enSrp) then
         retConf(SRP_INDEX_C).connectivity := x"FFFF";
      else
         retConf(SRP_INDEX_C).connectivity := x"0000";
      end if;
      for i in 7 downto 0 loop
         if (ETH_CONFIG_G.numSrvData >= (i+1)) then
            retConf(SRV_INDEX_C+i).connectivity := x"FFFF";
         else
            retConf(SRV_INDEX_C+i).connectivity := x"0000";
         end if;
         if (ETH_CONFIG_G.numCltData >= (i+1)) then
            retConf(CLT_INDEX_C+i).connectivity := x"FFFF";
         else
            retConf(CLT_INDEX_C+i).connectivity := x"0000";
         end if;
      end loop;

      return retConf;
   end function;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := myGenAxiLiteConfig;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal obServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal obServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal ibServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal ibServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal obClientMasters : AxiStreamMasterArray(CLIENT_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal obClientSlaves  : AxiStreamSlaveArray(CLIENT_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal ibClientMasters : AxiStreamMasterArray(CLIENT_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal ibClientSlaves  : AxiStreamSlaveArray(CLIENT_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal srpObMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal srpObSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
   signal srpIbMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal srpIbSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

begin

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
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

   ----------------------
   -- IPv4/ARP/UDP Engine
   ----------------------
   U_UdpEngineWrapper : entity surf.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => SERVER_SIZE_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => CLIENT_EN_C,
         CLIENT_SIZE_G  => CLIENT_SIZE_C,
         CLIENT_PORTS_G => CLIENT_PORTS_C,
         -- IPv4/ARP Generics
         CLK_FREQ_G     => AXIL_CLK_FREQ_C,      -- In units of Hz
         COMM_TIMEOUT_G => 30,  -- In units of seconds, Client's Communication timeout before re-ARPing  
         DHCP_G         => ETH_CONFIG_G.enDhcp)  -- no DHCP       
      port map (
         -- Local Configurations
         localMac        => localMac,
         localIp         => localIp,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => obMacMaster,
         obMacSlave      => obMacSlave,
         ibMacMaster     => ibMacMaster,
         ibMacSlave      => ibMacSlave,
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Interface to UDP Client engine(s)
         obClientMasters => obClientMasters,
         obClientSlaves  => obClientSlaves,
         ibClientMasters => ibClientMasters,
         ibClientSlaves  => ibClientSlaves,
         -- AXI-Lite Interface
         axilReadMaster  => axilReadMasters(UDP_INDEX_C),
         axilReadSlave   => axilReadSlaves(UDP_INDEX_C),
         axilWriteMaster => axilWriteMasters(UDP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(UDP_INDEX_C),
         -- Clock and Reset
         clk             => axilClk,
         rst             => axilRst);

   -------------
   -- Xilinx XVC
   -------------
   GEN_XVC : if (ETH_CONFIG_G.enXvc) generate
      U_Debug : entity surf.UdpDebugBridgeWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Clock and Reset
            clk        => axilClk,
            rst        => axilRst,
            -- UDP XVC Interface
            obServerMaster => obServerMasters(UDP_SRV_XVC_IDX_C),
            obServerSlave  => obServerSlaves(UDP_SRV_XVC_IDX_C),
            ibServerMaster => ibServerMasters(UDP_SRV_XVC_IDX_C),
            ibServerSlave  => ibServerSlaves(UDP_SRV_XVC_IDX_C));
   end generate;

   GEN_SRP : if (ETH_CONFIG_G.enSrp) generate
      U_RssiServer : entity surf.RssiCoreWrapper
         generic map (
            TPD_G               => TPD_G,
            SERVER_G            => true,
            CLK_FREQUENCY_G     => AXIL_CLK_FREQ_C,
            TIMEOUT_UNIT_G      => TIMEOUT_C,
            APP_ILEAVE_EN_G     => true,  -- true = AxiStreamPacketizer2
            APP_STREAMS_G       => 1,
            SEGMENT_ADDR_SIZE_G => bitSize(1024/8),
            WINDOW_ADDR_SIZE_G  => 3,
            SYNTH_MODE_G        => "xpm",
            MEMORY_TYPE_G       => "block",
            -- AXIS Configurations
            APP_AXIS_CONFIG_G   => SRP_AXIS_CONFIG_C,
            TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
            -- Window parameters of receiver module
            MAX_NUM_OUTS_SEG_G  => (2**3),
            MAX_SEG_SIZE_G      => 1024,
            -- Counters
            MAX_RETRANS_CNT_G   => (2**3),
            MAX_CUM_ACK_CNT_G   => 3)
         port map (
            clk_i                => axilClk,
            rst_i                => axilRst,
            -- Application Layer Interface
            sAppAxisMasters_i(0) => srpObMaster,
            sAppAxisSlaves_o(0)  => srpObSlave,
            mAppAxisMasters_o(0) => srpIbMaster,
            mAppAxisSlaves_i(0)  => srpIbSlave,
            -- Transport Layer Interface
            sTspAxisMaster_i     => obServerMasters(UDP_SRV_SRP_IDX_C),
            sTspAxisSlave_o      => obServerSlaves(UDP_SRV_SRP_IDX_C),
            mTspAxisMaster_o     => ibServerMasters(UDP_SRV_SRP_IDX_C),
            mTspAxisSlave_i      => ibServerSlaves(UDP_SRV_SRP_IDX_C),
            -- High level  Application side interface
            openRq_i             => '1',  -- Automatically start the connection without debug SRP channel
            closeRq_i            => '0',
            inject_i             => '0',
            -- AXI-Lite Interface
            axiClk_i             => axilClk,
            axiRst_i             => axilRst,
            axilReadMaster       => axilReadMasters(SRP_INDEX_C),
            axilReadSlave        => axilReadSlaves(SRP_INDEX_C),
            axilWriteMaster      => axilWriteMasters(SRP_INDEX_C),
            axilWriteSlave       => axilWriteSlaves(SRP_INDEX_C));

      ------------------
      -- AXI-Lite Master
      ------------------
      U_SRPv3 : entity surf.SrpV3AxiLite
         generic map (
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => true,
            GEN_SYNC_FIFO_G     => true,
            AXI_STREAM_CONFIG_G => SRP_AXIS_CONFIG_C(0))
         port map (
            -- AXIS Slave Interface (sAxisClk domain)
            sAxisClk         => axilClk,
            sAxisRst         => axilRst,
            sAxisMaster      => srpIbMaster,
            sAxisSlave       => srpIbSlave,
            -- AXIS Master Interface (mAxisClk domain) 
            mAxisClk         => axilClk,
            mAxisRst         => axilRst,
            mAxisMaster      => srpObMaster,
            mAxisSlave       => srpObSlave,
            -- Master AXI-Lite Interface (axilClk domain)
            axilClk          => axilClk,
            axilRst          => axilRst,
            mAxilReadMaster  => mAxilReadMaster,
            mAxilReadSlave   => mAxilReadSlave,
            mAxilWriteMaster => mAxilWriteMaster,
            mAxilWriteSlave  => mAxilWriteSlave);
   end generate;

   GEN_SRV : if (ETH_CONFIG_G.numSrvData /= 0) generate
      GEN_CH :
      for i in (ETH_CONFIG_G.numSrvData-1) downto 0 generate
         U_Rssi : entity surf.RssiCoreWrapper
            generic map (
               TPD_G               => TPD_G,
               SERVER_G            => true,
               CLK_FREQUENCY_G     => AXIL_CLK_FREQ_C,
               TIMEOUT_UNIT_G      => TIMEOUT_C,
               APP_ILEAVE_EN_G     => true,  -- true = AxiStreamPacketizer2
               APP_STREAMS_G       => 1,
               SEGMENT_ADDR_SIZE_G => bitSize(MAX_SEG_SIZE_C/8),
               WINDOW_ADDR_SIZE_G  => WINDOW_ADDR_SIZE_C,
               BYP_TX_BUFFER_G     => not(ETH_CONFIG_G.enSrvDataTx),
               BYP_RX_BUFFER_G     => not(ETH_CONFIG_G.enSrvDataRx),
               SYNTH_MODE_G        => SYNTH_MODE_C,
               MEMORY_TYPE_G       => MEMORY_TYPE_C,
               -- AXIS Configurations
               APP_AXIS_CONFIG_G   => DATA_AXIS_CONFIG_C,
               TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
               -- Window parameters of receiver module
               MAX_NUM_OUTS_SEG_G  => (2**WINDOW_ADDR_SIZE_C),
               MAX_SEG_SIZE_G      => MAX_SEG_SIZE_C,
               -- Counters
               MAX_RETRANS_CNT_G   => (2**WINDOW_ADDR_SIZE_C),
               MAX_CUM_ACK_CNT_G   => WINDOW_ADDR_SIZE_C)
            port map (
               clk_i                => axilClk,
               rst_i                => axilRst,
               -- Application Layer Interface
               sAppAxisMasters_i(0) => srvIbMasters(i),
               sAppAxisSlaves_o(0)  => srvIbSlaves(i),
               mAppAxisMasters_o(0) => srvObMasters(i),
               mAppAxisSlaves_i(0)  => srvObSlaves(i),
               -- Transport Layer Interface
               sTspAxisMaster_i     => obServerMasters(UDP_SRV_DATA_IDX_C+i),
               sTspAxisSlave_o      => obServerSlaves(UDP_SRV_DATA_IDX_C+i),
               mTspAxisMaster_o     => ibServerMasters(UDP_SRV_DATA_IDX_C+i),
               mTspAxisSlave_i      => ibServerSlaves(UDP_SRV_DATA_IDX_C+i),
               -- High level  Application side interface
               openRq_i             => '1',  -- Automatically start the connection without debug SRP channel
               closeRq_i            => '0',
               inject_i             => '0',
               -- AXI-Lite Interface
               axiClk_i             => axilClk,
               axiRst_i             => axilRst,
               axilReadMaster       => axilReadMasters(SRV_INDEX_C+i),
               axilReadSlave        => axilReadSlaves(SRV_INDEX_C+i),
               axilWriteMaster      => axilWriteMasters(SRV_INDEX_C+i),
               axilWriteSlave       => axilWriteSlaves(SRV_INDEX_C+i));
      end generate GEN_CH;
   end generate;

   GEN_CLT : if (ETH_CONFIG_G.numCltData /= 0) generate
      GEN_CH :
      for i in (ETH_CONFIG_G.numCltData-1) downto 0 generate
         U_Rssi : entity surf.RssiCoreWrapper
            generic map (
               TPD_G               => TPD_G,
               SERVER_G            => false,  -- false = Client mode
               CLK_FREQUENCY_G     => AXIL_CLK_FREQ_C,
               TIMEOUT_UNIT_G      => TIMEOUT_C,
               APP_ILEAVE_EN_G     => true,   -- true = AxiStreamPacketizer2
               APP_STREAMS_G       => 1,
               SEGMENT_ADDR_SIZE_G => bitSize(MAX_SEG_SIZE_C/8),
               WINDOW_ADDR_SIZE_G  => WINDOW_ADDR_SIZE_C,
               BYP_TX_BUFFER_G     => not(ETH_CONFIG_G.enCltDataTx),
               BYP_RX_BUFFER_G     => not(ETH_CONFIG_G.enCltDataRx),
               SYNTH_MODE_G        => SYNTH_MODE_C,
               MEMORY_TYPE_G       => MEMORY_TYPE_C,
               -- AXIS Configurations
               APP_AXIS_CONFIG_G   => DATA_AXIS_CONFIG_C,
               TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
               -- Window parameters of receiver module
               MAX_NUM_OUTS_SEG_G  => (2**WINDOW_ADDR_SIZE_C),
               MAX_SEG_SIZE_G      => MAX_SEG_SIZE_C,
               -- Counters
               MAX_RETRANS_CNT_G   => (2**WINDOW_ADDR_SIZE_C),
               MAX_CUM_ACK_CNT_G   => WINDOW_ADDR_SIZE_C)
            port map (
               clk_i                => axilClk,
               rst_i                => axilRst,
               -- Application Layer Interface
               sAppAxisMasters_i(0) => cltIbMasters(i),
               sAppAxisSlaves_o(0)  => cltIbSlaves(i),
               mAppAxisMasters_o(0) => cltObMasters(i),
               mAppAxisSlaves_i(0)  => cltObSlaves(i),
               -- Transport Layer Interface
               sTspAxisMaster_i     => obClientMasters(UDP_CLT_DATA_IDX_C+i),
               sTspAxisSlave_o      => obClientSlaves(UDP_CLT_DATA_IDX_C+i),
               mTspAxisMaster_o     => ibClientMasters(UDP_CLT_DATA_IDX_C+i),
               mTspAxisSlave_i      => ibClientSlaves(UDP_CLT_DATA_IDX_C+i),
               -- High level  Application side interface
               openRq_i             => '0',   -- Enabled via software
               closeRq_i            => '0',
               inject_i             => '0',
               -- AXI-Lite Interface
               axiClk_i             => axilClk,
               axiRst_i             => axilRst,
               axilReadMaster       => axilReadMasters(CLT_INDEX_C+i),
               axilReadSlave        => axilReadSlaves(CLT_INDEX_C+i),
               axilWriteMaster      => axilWriteMasters(CLT_INDEX_C+i),
               axilWriteSlave       => axilWriteSlaves(CLT_INDEX_C+i));
      end generate GEN_CH;
   end generate;

end mapping;
