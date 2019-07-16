-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RX PHY Core module
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
use work.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggCore is
   generic (
      TPD_G        : time           := 1 ns;
      SIMULATION_G : boolean        := false;
      BUILD_INFO_G : BuildInfoType;
      ETH_CONFIG_G : EthConfigArray := (others => ETH_CONFIG_INIT_C));  -- ETH_CONFIG_G[3:0] = FAB_ETH[4:1], ETH_CONFIG_G[4] = BASE_ETH, ETH_CONFIG_G[5] = FP_ETH
   port (
      -----------------------------
      --  Interfaces to Application
      -----------------------------
      -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
      axilClk         : out   sl;
      axilRst         : out   sl;
      axilReadMaster  : out   AxiLiteReadMasterType;
      axilReadSlave   : in    AxiLiteReadSlaveType                            := AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C;
      axilWriteMaster : out   AxiLiteWriteMasterType;
      axilWriteSlave  : in    AxiLiteWriteSlaveType                           := AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C;
      -- Server Streaming Interface (axilClk domain)
      srvIbMasters    : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvIbSlaves     : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      srvObMasters    : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvObSlaves     : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Client Streaming Interface (axilClk domain)
      cltIbMasters    : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltIbSlaves     : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      cltObMasters    : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltObSlaves     : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Misc. Interface 
      ref156Clk       : out   sl;
      ref156Rst       : out   sl;
      ipmiBsi         : out   BsiBusType;
      ledRedL         : out   slv(1 downto 0);
      ledBlueL        : out   slv(1 downto 0);
      ledGreenL       : out   slv(1 downto 0);
      -------------------   
      --  Top Level Ports
      -------------------   
      -- Jitter Cleaner PLL Ports
      pllSpiCsL       : out   sl;
      pllSpiSclk      : out   sl;
      pllSpiSdi       : out   sl;
      pllSpiSdo       : in    sl;
      pllSpiRstL      : out   sl;
      pllSpiOeL       : out   sl;
      pllIntrL        : in    sl;
      pllLolL         : in    sl;
      pllClkScl       : inout sl;
      pllClkSda       : inout sl;
      -- Front Panel I2C Ports
      fpScl           : inout sl;
      fpSda           : inout sl;
      sfpScl          : inout slv(3 downto 0);
      sfpSda          : inout slv(3 downto 0);
      qsfpScl         : inout slv(1 downto 0);
      qsfpSda         : inout slv(1 downto 0);
      -- Front Panel: ETH[1:0] SGMII Ports
      sgmiiClkP       : in    sl;
      sgmiiClkN       : in    sl;
      sgmiiRxP        : in    slv(1 downto 0);
      sgmiiRxN        : in    slv(1 downto 0);
      sgmiiTxP        : out   slv(1 downto 0);
      sgmiiTxN        : out   slv(1 downto 0);
      -- ATCA Backplane: FABRIC ETH[1:4]
      fabEthRefClkP   : in    sl;
      fabEthRefClkN   : in    sl;
      fabEthTxP       : out   Slv4Array(4 downto 1);
      fabEthTxN       : out   Slv4Array(4 downto 1);
      fabEthRxP       : in    Slv4Array(4 downto 1);
      fabEthRxN       : in    Slv4Array(4 downto 1);
      -- IMPC Ports
      ipmcScl         : inout sl;
      ipmcSda         : inout sl;
      -- SYSMON Ports
      vPIn            : in    sl;
      vNIn            : in    sl);
end AtlasAtcaLinkAggCore;

architecture mapping of AtlasAtcaLinkAggCore is

   function genRouteTable
      return slv is
      variable retVar : slv(15 downto 0);
   begin
      retVar := x"0000";
      for i in NUM_ETH_C-1 downto 0 loop
         if (ETH_CONFIG_G(i).enable) and (ETH_CONFIG_G(i).enSrp) then
            retVar(i) := '1';
         end if;
      end loop;
      return retVar;
   end function;
   constant M_AXIL_CONNECT_C : slv(15 downto 0) := genRouteTable;

   constant NUM_AXIL_MASTERS_C : positive := 4;

   constant BASE_INDEX_C    : natural := 0;
   constant PLL_SPI_INDEX_C : natural := 1;
   constant ETH_INDEX_C     : natural := 2;
   constant APP_INDEX_C     : natural := 3;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      BASE_INDEX_C    => (
         baseAddr     => x"0000_0000",
         addrBits     => 16,
         connectivity => M_AXIL_CONNECT_C),
      PLL_SPI_INDEX_C => (
         baseAddr     => x"0001_0000",
         addrBits     => 16,
         connectivity => M_AXIL_CONNECT_C),
      ETH_INDEX_C     => (
         baseAddr     => x"0100_0000",
         addrBits     => 24,
         connectivity => M_AXIL_CONNECT_C),
      APP_INDEX_C     => (
         baseAddr     => APP_AXIL_BASE_ADDR_C,
         addrBits     => 31,
         connectivity => M_AXIL_CONNECT_C));

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal mAxilReadMasters  : AxiLiteReadMasterArray(NUM_ETH_C-1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_ETH_C-1 downto 0);
   signal mAxilWriteMasters : AxiLiteWriteMasterArray(NUM_ETH_C-1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_ETH_C-1 downto 0);

   signal bsiBus    : BsiBusType;
   signal localIp   : Slv32Array(NUM_ETH_C-1 downto 0);
   signal ethLinkUp : slv(NUM_ETH_C-1 downto 0);

   signal axilClock    : sl;
   signal axilReset    : sl;
   signal ref156Clock  : sl;
   signal ref156Reset  : sl;
   signal eth125Clk    : sl;
   signal eth125Rst    : sl;
   signal eth62Clk     : sl;
   signal eth62Rst     : sl;
   signal fabEthRefClk : sl;

begin

   axilClk <= axilClock;
   U_axilRst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => axilClock,
         rstIn  => axilReset,
         rstOut => axilRst);

   ref156Clk <= ref156Clock;
   U_ref156Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ref156Clock,
         rstIn  => ref156Reset,
         rstOut => ref156Rst);

   pllSpiOeL <= '0';
   U_pllSpiRstL : entity work.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '0',
         SIM_SPEEDUP_G  => SIMULATION_G)
      port map (
         clk    => axilClock,
         arst   => axilReset,
         rstOut => pllSpiRstL);

   process(bsiBus)
      variable tmp : BsiBusType;
   begin
      tmp := bsiBus;
      for i in NUM_ETH_C-1 downto 0 loop
         if (ETH_CONFIG_G(i).enable) then
            -- Prevent application from using allocated MAC address
            tmp.macAddress(i) := (others => '0');
         end if;
      end loop;
      ipmiBsi <= tmp;
   end process;

   --------------------------------
   -- Common Clock and Reset Module
   -------------------------------- 
   U_ClkRst : entity work.AtlasAtcaLinkAggClk
      generic map(
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G)
      port map(
         axilClk       => axilClock,
         axilRst       => axilReset,
         ref156Clk     => ref156Clock,
         ref156Rst     => ref156Reset,
         eth125Clk     => eth125Clk,
         eth125Rst     => eth125Rst,
         eth62Clk      => eth62Clk,
         eth62Rst      => eth62Rst,
         fabEthRefClkP => fabEthRefClkP,
         fabEthRefClkN => fabEthRefClkN,
         fabEthRefClk  => fabEthRefClk);

   ------------------
   -- Ethernet Module
   ------------------
   U_Eth : entity work.AtlasAtcaLinkAggEth
      generic map (
         TPD_G            => TPD_G,
         SIMULATION_G     => SIMULATION_G,
         AXIL_BASE_ADDR_G => XBAR_CONFIG_C(ETH_INDEX_C).baseAddr,
         ETH_CONFIG_G     => ETH_CONFIG_G)
      port map (
         -- Clocks and Resets
         axilClk           => axilClock,
         axilRst           => axilReset,
         ref156Clk         => ref156Clock,
         ref156Rst         => ref156Reset,
         eth125Clk         => eth125Clk,
         eth125Rst         => eth125Rst,
         eth62Clk          => eth62Clk,
         eth62Rst          => eth62Rst,
         -- AXI-Lite Slave Interface
         sAxilReadMaster   => axilReadMasters(ETH_INDEX_C),
         sAxilReadSlave    => axilReadSlaves(ETH_INDEX_C),
         sAxilWriteMaster  => axilWriteMasters(ETH_INDEX_C),
         sAxilWriteSlave   => axilWriteSlaves(ETH_INDEX_C),
         -- AXI-Lite Master Interfaces
         mAxilReadMasters  => mAxilReadMasters,
         mAxilReadSlaves   => mAxilReadSlaves,
         mAxilWriteMasters => mAxilWriteMasters,
         mAxilWriteSlaves  => mAxilWriteSlaves,
         -- Server Streaming Interface (axilClk domain)
         srvIbMasters      => srvIbMasters,
         srvIbSlaves       => srvIbSlaves,
         srvObMasters      => srvObMasters,
         srvObSlaves       => srvObSlaves,
         -- Client Streaming Interface (axilClk domain)
         cltIbMasters      => cltIbMasters,
         cltIbSlaves       => cltIbSlaves,
         cltObMasters      => cltObMasters,
         cltObSlaves       => cltObSlaves,
         -- Local Configuration
         localMac          => bsiBus.macAddress,
         localIp           => localIp,
         ethLinkUp         => ethLinkUp,
         -------------------   
         --  Top Level Ports
         -------------------      
         -- Front Panel: ETH[1:0] SGMII Ports
         sgmiiClkP         => sgmiiClkP,
         sgmiiClkN         => sgmiiClkN,
         sgmiiTxP          => sgmiiTxP,
         sgmiiTxN          => sgmiiTxN,
         sgmiiRxP          => sgmiiRxP,
         sgmiiRxN          => sgmiiRxN,
         -- ATCA Backplane: FABRIC ETH[1:4]
         fabEthRefClk      => fabEthRefClk,
         fabEthTxP         => fabEthTxP,
         fabEthTxN         => fabEthTxN,
         fabEthRxP         => fabEthRxP,
         fabEthRxN         => fabEthRxN);

   --------------------------
   -- AXI-Lite: Crossbar Core
   --------------------------  
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => NUM_ETH_C,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk           => axilClock,
         axiClkRst        => axilReset,
         sAxiWriteMasters => mAxilWriteMasters,
         sAxiWriteSlaves  => mAxilWriteSlaves,
         sAxiReadMasters  => mAxilReadMasters,
         sAxiReadSlaves   => mAxilReadSlaves,
         mAxiWriteMasters => axilWriteMasters,
         mAxiWriteSlaves  => axilWriteSlaves,
         mAxiReadMasters  => axilReadMasters,
         mAxiReadSlaves   => axilReadSlaves);

   -------------------
   -- System Registers
   -------------------    
   U_SysReg : entity work.AtlasAtcaLinkAggReg
      generic map (
         TPD_G            => TPD_G,
         SIMULATION_G     => SIMULATION_G,
         AXIL_BASE_ADDR_G => XBAR_CONFIG_C(BASE_INDEX_C).baseAddr,
         BUILD_INFO_G     => BUILD_INFO_G)
      port map (
         -- AXI-Lite Interface
         axilClk         => axilClock,
         axilRst         => axilReset,
         axilReadMaster  => axilReadMasters(BASE_INDEX_C),
         axilReadSlave   => axilReadSlaves(BASE_INDEX_C),
         axilWriteMaster => axilWriteMasters(BASE_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(BASE_INDEX_C),
         -- Misc. Interface 
         localIp         => localIp,
         ethLinkUp       => ethLinkUp,
         bsiBus          => bsiBus,
         ledRedL         => ledRedL,
         ledBlueL        => ledBlueL,
         ledGreenL       => ledGreenL,
         -------------------   
         --  Top Level Ports
         -------------------   
         -- Jitter Cleaner PLL Ports
         pllClkScl       => pllClkScl,
         pllClkSda       => pllClkSda,
         -- Front Panel I2C Ports
         fpScl           => fpScl,
         fpSda           => fpSda,
         sfpScl          => sfpScl,
         sfpSda          => sfpSda,
         qsfpScl         => qsfpScl,
         qsfpSda         => qsfpSda,
         -- IMPC Ports
         ipmcScl         => ipmcScl,
         ipmcSda         => ipmcSda,
         -- SYSMON Ports
         vPIn            => vPIn,
         vNIn            => vNIn);

   NOT_SIM : if (SIMULATION_G = false) generate
      U_PLL_SPI : entity work.Si5345
         generic map (
            TPD_G             => TPD_G,
            CLK_PERIOD_G      => AXIL_CLK_PERIOD_C,
            SPI_SCLK_PERIOD_G => (1/10.0E+6))  -- 1/(10 MHz SCLK)
         port map (
            -- AXI-Lite Register Interface
            axiClk         => axilClock,
            axiRst         => axilReset,
            axiReadMaster  => axilReadMasters(PLL_SPI_INDEX_C),
            axiReadSlave   => axilReadSlaves(PLL_SPI_INDEX_C),
            axiWriteMaster => axilWriteMasters(PLL_SPI_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(PLL_SPI_INDEX_C),
            -- SPI Ports
            coreSclk       => pllSpiSclk,
            coreSDin       => pllSpiSdo,
            coreSDout      => pllSpiSdi,
            coreCsb        => pllSpiCsL);
   end generate;

   -------------------------------------------
   -- Map the AXI-Lite to Application Firmware
   -------------------------------------------
   axilReadMaster               <= axilReadMasters(APP_INDEX_C);
   axilReadSlaves(APP_INDEX_C)  <= axilReadSlave;
   axilWriteMaster              <= axilWriteMasters(APP_INDEX_C);
   axilWriteSlaves(APP_INDEX_C) <= axilWriteSlave;

end mapping;
