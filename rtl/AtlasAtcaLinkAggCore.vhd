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
use work.I2cPkg.all;
use work.AtlasAtcaLinkAggPkg.all;
use work.AtlasAtcaLinkAggRegPkg.all;

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
      sfpScl          : inout slv(4 downto 0);
      sfpSda          : inout slv(4 downto 0);
      qsfpScl         : inout slv(1 downto 0);
      qsfpSda         : inout slv(1 downto 0);
      -- Front Panel LVDS SGMII Ports
      fpEthTxP        : out   sl;
      fpEthTxN        : out   sl;
      fpEthRxP        : in    sl;
      fpEthRxN        : in    sl;
      -- ATCA Backplane: BASE ETH[1] Ports
      baseEthRefClkP  : in    sl;
      baseEthRefClkN  : in    sl;
      baseEthTxP      : out   sl;
      baseEthTxN      : out   sl;
      baseEthRxP      : in    sl;
      baseEthRxN      : in    sl;
      baseEthMdio     : inout sl;
      baseEthMdc      : out   sl;
      baseEthRstL     : out   sl;
      baseEthIrqL     : in    sl;
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

   signal mAxilReadMasters  : AxiLiteReadMasterArray(NUM_ETH_C-1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_ETH_C-1 downto 0);
   signal mAxilWriteMasters : AxiLiteWriteMasterArray(NUM_ETH_C-1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_ETH_C-1 downto 0);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C(0)-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C(0)-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C(0)-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C(0)-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal baseWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C(1)-1 downto 0);
   signal baseWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C(1)-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal baseReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C(1)-1 downto 0);
   signal baseReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C(1)-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

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

   signal axilRstL  : sl;
   signal bootCmd   : sl;
   signal bootReq   : sl;
   signal bootstart : sl;
   signal bootAddr  : slv(31 downto 0);
   signal upTimeCnt : slv(31 downto 0);

   signal bootCsL  : sl;
   signal bootSck  : sl;
   signal bootMosi : sl;
   signal bootMiso : sl;
   signal di       : slv(3 downto 0);
   signal do       : slv(3 downto 0);

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
         AXIL_BASE_ADDR_G => XBAR_CONFIG_0_C(ETH_INDEX_C).baseAddr,
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
         -- Front Panel LVDS SGMII Ports
         fpEthTxP          => fpEthTxP,
         fpEthTxN          => fpEthTxN,
         fpEthRxP          => fpEthRxP,
         fpEthRxN          => fpEthRxN,
         -- ATCA Backplane: BASE ETH[1] Ports
         baseEthRefClkP    => baseEthRefClkP,
         baseEthRefClkN    => baseEthRefClkN,
         baseEthTxP        => baseEthTxP,
         baseEthTxN        => baseEthTxN,
         baseEthRxP        => baseEthRxP,
         baseEthRxN        => baseEthRxN,
         baseEthMdio       => baseEthMdio,
         baseEthMdc        => baseEthMdc,
         baseEthRstL       => baseEthRstL,
         baseEthIrqL       => baseEthIrqL,
         -- ATCA Backplane: FABRIC ETH[1:4]
         fabEthRefClk      => fabEthRefClk,
         fabEthTxP         => fabEthTxP,
         fabEthTxN         => fabEthTxN,
         fabEthRxP         => fabEthRxP,
         fabEthRxN         => fabEthRxN);

   --------------------------
   -- AXI-Lite: Crossbar Core
   --------------------------  
   U_XBAR_0 : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 6,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C(0),
         MASTERS_CONFIG_G   => XBAR_CONFIG_0_C)
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

   U_XBAR_1 : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C(1),
         MASTERS_CONFIG_G   => XBAR_CONFIG_1_C)
      port map (
         axiClk              => axilClock,
         axiClkRst           => axilReset,
         sAxiWriteMasters(0) => axilWriteMasters(BASE_INDEX_C),
         sAxiWriteSlaves(0)  => axilWriteSlaves(BASE_INDEX_C),
         sAxiReadMasters(0)  => axilReadMasters(BASE_INDEX_C),
         sAxiReadSlaves(0)   => axilReadSlaves(BASE_INDEX_C),
         mAxiWriteMasters    => baseWriteMasters,
         mAxiWriteSlaves     => baseWriteSlaves,
         mAxiReadMasters     => baseReadMasters,
         mAxiReadSlaves      => baseReadSlaves);

   --------------------------
   -- AXI-Lite Version Module
   --------------------------
   U_Version : entity work.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_PERIOD_G    => AXIL_CLK_PERIOD_C,
         XIL_DEVICE_G    => XIL_DEVICE_C,
         EN_DEVICE_DNA_G => true)
      port map (
         -- AXI-Lite Interface
         axiClk         => axilClock,
         axiRst         => axilReset,
         upTimeCnt      => upTimeCnt,
         fpgaReload     => bootCmd,
         axiReadMaster  => baseReadMasters(VERSION_INDEX_C),
         axiReadSlave   => baseReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => baseWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => baseWriteSlaves(VERSION_INDEX_C));

   bootstart <= bootCmd or bootReq;

   -----------------------
   -- AXI-Lite: BSI Module
   -----------------------
   U_Bsi : entity work.AtlasAtcaLinkAggBsi
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G)
      port map (
         -- Local Configurations
         bsiBus          => bsiBus,
         localIp         => localIp,
         ethLinkUp       => ethLinkUp,
         bootReq         => bootReq,
         bootAddr        => bootAddr,
         upTimeCnt       => upTimeCnt,
         -- I2C Ports
         scl             => ipmcScl,
         sda             => ipmcSda,
         -- AXI-Lite Register Interface
         axilReadMaster  => baseReadMasters(IPMC_INDEX_C),
         axilReadSlave   => baseReadSlaves(IPMC_INDEX_C),
         axilWriteMaster => baseWriteMasters(IPMC_INDEX_C),
         axilWriteSlave  => baseWriteSlaves(IPMC_INDEX_C),
         -- Clocks and Resets
         axilClk         => axilClock,
         axilRst         => axilReset);

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

   NOT_SIM : if (SIMULATION_G = false) generate

      U_Iprog : entity work.Iprog
         generic map (
            TPD_G        => TPD_G,
            XIL_DEVICE_G => XIL_DEVICE_C)
         port map (
            clk         => axilClock,
            rst         => axilReset,
            start       => bootstart,
            bootAddress => bootAddr);

      U_SysMon : entity work.AtlasAtcaLinkAggSysMon
         generic map (
            TPD_G => TPD_G)
         port map (
            -- SYSMON Ports
            vPIn            => vPIn,
            vNIn            => vNIn,
            -- AXI-Lite Register Interface
            axilReadMaster  => baseReadMasters(SYSMON_INDEX_C),
            axilReadSlave   => baseReadSlaves(SYSMON_INDEX_C),
            axilWriteMaster => baseWriteMasters(SYSMON_INDEX_C),
            axilWriteSlave  => baseWriteSlaves(SYSMON_INDEX_C),
            -- Clocks and Resets
            axilClk         => axilClock,
            axilRst         => axilReset);

      U_BootProm : entity work.AxiMicronN25QCore
         generic map (
            TPD_G          => TPD_G,
            AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C,        -- units of Hz
            SPI_CLK_FREQ_G => (AXIL_CLK_FREQ_C/4.0))  -- units of Hz
         port map (
            -- FLASH Memory Ports
            csL            => bootCsL,
            sck            => bootSck,
            mosi           => bootMosi,
            miso           => bootMiso,
            -- AXI-Lite Register Interface
            axiReadMaster  => baseReadMasters(BOOT_MEM_INDEX_C),
            axiReadSlave   => baseReadSlaves(BOOT_MEM_INDEX_C),
            axiWriteMaster => baseWriteMasters(BOOT_MEM_INDEX_C),
            axiWriteSlave  => baseWriteSlaves(BOOT_MEM_INDEX_C),
            -- Clocks and Resets
            axiClk         => axilClock,
            axiRst         => axilReset);

      U_STARTUPE3 : STARTUPE3
         generic map (
            PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
            SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
         port map (
            CFGCLK    => open,  -- 1-bit output: Configuration main clock output
            CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
            DI        => di,  -- 4-bit output: Allow receiving on the D[3:0] input pins
            EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
            PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output
            DO        => do,  -- 4-bit input: Allows control of the D[3:0] pin outputs
            DTS       => "1110",  -- 4-bit input: Allows tristate of the D[3:0] pins
            FCSBO     => bootCsL,  -- 1-bit input: Contols the FCS_B pin for flash access
            FCSBTS    => '0',           -- 1-bit input: Tristate the FCS_B pin
            GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
            GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
            KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
            PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
            USRCCLKO  => bootSck,       -- 1-bit input: User CCLK input
            USRCCLKTS => '0',  -- 1-bit input: User CCLK 3-state enable input
            USRDONEO  => axilRstL,  -- 1-bit input: User DONE pin output control
            USRDONETS => '0');  -- 1-bit input: User DONE 3-state enable output

      axilRstL <= not(axilReset);  -- IPMC uses DONE to determine if FPGA is ready
      do       <= "111" & bootMosi;
      bootMiso <= di(1);

      GEN_SFP :
      for i in 4 downto 0 generate
         U_I2C : entity work.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               DEVICE_MAP_G   => SFF8472_I2C_CONFIG_C,
               AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
            port map (
               -- I2C Ports
               scl            => sfpScl(i),
               sda            => sfpSda(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => baseReadMasters(SFP_I2C_INDEX_C+i),
               axiReadSlave   => baseReadSlaves(SFP_I2C_INDEX_C+i),
               axiWriteMaster => baseWriteMasters(SFP_I2C_INDEX_C+i),
               axiWriteSlave  => baseWriteSlaves(SFP_I2C_INDEX_C+i),
               -- Clocks and Resets
               axiClk         => axilClock,
               axiRst         => axilReset);
      end generate GEN_SFP;

      GEN_QSFP :
      for i in 1 downto 0 generate
         U_I2C : entity work.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               DEVICE_MAP_G   => SFF8472_I2C_CONFIG_C,
               AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
            port map (
               -- I2C Ports
               scl            => qsfpScl(i),
               sda            => qsfpSda(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => baseReadMasters(QSFP_I2C_INDEX_C+i),
               axiReadSlave   => baseReadSlaves(QSFP_I2C_INDEX_C+i),
               axiWriteMaster => baseWriteMasters(QSFP_I2C_INDEX_C+i),
               axiWriteSlave  => baseWriteSlaves(QSFP_I2C_INDEX_C+i),
               -- Clocks and Resets
               axiClk         => axilClock,
               axiRst         => axilReset);
      end generate GEN_QSFP;

      U_FP_I2C : entity work.AxiI2cRegMaster
         generic map (
            TPD_G          => TPD_G,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            DEVICE_MAP_G   => FP_I2C_CONFIG_C,
            AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
         port map (
            -- I2C Ports
            scl            => fpScl,
            sda            => fpSda,
            -- AXI-Lite Register Interface
            axiReadMaster  => baseReadMasters(FP_I2C_INDEX_C),
            axiReadSlave   => baseReadSlaves(FP_I2C_INDEX_C),
            axiWriteMaster => baseWriteMasters(FP_I2C_INDEX_C),
            axiWriteSlave  => baseWriteSlaves(FP_I2C_INDEX_C),
            -- Clocks and Resets
            axiClk         => axilClock,
            axiRst         => axilReset);

      U_PLL_I2C : entity work.AxiI2cRegMaster
         generic map (
            TPD_G          => TPD_G,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            DEVICE_MAP_G   => PLL_I2C_CONFIG_C,
            AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
         port map (
            -- I2C Ports
            scl            => pllClkScl,
            sda            => pllClkSda,
            -- AXI-Lite Register Interface
            axiReadMaster  => baseReadMasters(PLL_I2C_INDEX_C),
            axiReadSlave   => baseReadSlaves(PLL_I2C_INDEX_C),
            axiWriteMaster => baseWriteMasters(PLL_I2C_INDEX_C),
            axiWriteSlave  => baseWriteSlaves(PLL_I2C_INDEX_C),
            -- Clocks and Resets
            axiClk         => axilClock,
            axiRst         => axilReset);

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
