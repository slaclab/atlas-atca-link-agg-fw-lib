-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggReg.vhd
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

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggReg is
   generic (
      TPD_G            : time             := 1 ns;
      SIMULATION_G     : boolean          := false;
      BUILD_INFO_G     : BuildInfoType;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := (others => '0'));
   port (
      -- AXI-Lite Interface
      axilClk         : in    sl;
      axilRst         : in    sl;
      axilReadMaster  : in    AxiLiteReadMasterType;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- Misc. Interface 
      localIp         : out   Slv32Array(NUM_ETH_C-1 downto 0);
      ethLinkUp       : in    slv(NUM_ETH_C-1 downto 0);
      bsiBus          : out   BsiBusType;
      ledRedL         : out   slv(1 downto 0);
      ledBlueL        : out   slv(1 downto 0);
      ledGreenL       : out   slv(1 downto 0);
      -------------------   
      --  Top Level Ports
      -------------------   
      -- Jitter Cleaner PLL Ports
      pllClkScl       : inout sl;
      pllClkSda       : inout sl;
      -- Front Panel I2C Ports
      fpScl           : inout sl;
      fpSda           : inout sl;
      sfpScl          : inout slv(3 downto 0);
      sfpSda          : inout slv(3 downto 0);
      qsfpScl         : inout slv(1 downto 0);
      qsfpSda         : inout slv(1 downto 0);
      -- IMPC Ports
      ipmcScl         : inout sl;
      ipmcSda         : inout sl;
      -- SYSMON Ports
      vPIn            : in    sl;
      vNIn            : in    sl);
end AtlasAtcaLinkAggReg;

architecture mapping of AtlasAtcaLinkAggReg is

   constant PLL_I2C_CONFIG_C : I2cAxiLiteDevArray(0 downto 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1011000",      -- LMK61E2
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian   
         repeatStart => '1'));          -- Repeat Start    

   constant FP_I2C_CONFIG_C : I2cAxiLiteDevArray(0 downto 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100000",      -- PCA9506DGG
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian   
         repeatStart => '1'));          -- Repeat Start             

   constant SFF8472_I2C_CONFIG_C : I2cAxiLiteDevArray(1 downto 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010000",      -- 2 wire address 1010000X (A0h)
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian                   
         repeatStart => '1'),           -- No repeat start                   
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010001",      -- 2 wire address 1010001X (A2h)
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian   
         repeatStart => '1'));          -- Repeat Start 

   constant NUM_AXIL_MASTERS_C : positive := 12;

   constant VERSION_INDEX_C  : natural := 0;
   constant SYSMON_INDEX_C   : natural := 1;
   constant BOOT_MEM_INDEX_C : natural := 2;
   constant IPMC_INDEX_C     : natural := 3;
   constant SFP_I2C_INDEX_C  : natural := 4;  -- [4:7]
   constant QSFP_I2C_INDEX_C : natural := 8;  -- [8:9]
   constant FP_I2C_INDEX_C   : natural := 10;
   constant PLL_I2C_INDEX_C  : natural := 11;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 16, 12);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal axilRstL  : sl;
   signal bootRdy   : sl;
   signal bootArmed : sl;
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

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

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
         axiClk         => axilClk,
         axiRst         => axilRst,
         upTimeCnt      => upTimeCnt,
         fpgaReload     => bootCmd,
         axiReadMaster  => axilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => axilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => axilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(VERSION_INDEX_C));

   U_bootRdy : entity work.PwrUpRst
      generic map (
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '0',
         DURATION_G     => 937500000)  -- 6 seconds
      port map (
         clk    => axilClk,
         arst   => axilRst,
         rstOut => bootRdy);

   process(axilClk)
   begin
      if rising_edge(axilClk) then
         -- Check for reset
         if axilRst = '1' then
            bootArmed <= '0' after TPD_G;
            bootstart <= '0' after TPD_G;
         else
            -- Reset the flag
            bootstart <= '0' after TPD_G;
            -- Check for IPMI boot request or User boot cmd
            if (bootReq = '1') or (bootCmd = '1') then
               bootArmed <= '1' after TPD_G;
            end if;
            -- Check if DDR passed and armed
            if (bootRdy = '1') and (bootArmed = '1') then
               -- Set the flag
               bootstart <= '1' after TPD_G;
               -- Reset the flag
               bootArmed <= '0' after TPD_G;
            end if;
         end if;
      end if;
   end process;

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
         ledRedL         => ledRedL,
         ledBlueL        => ledBlueL,
         ledGreenL       => ledGreenL,
         -- I2C Ports
         scl             => ipmcScl,
         sda             => ipmcSda,
         -- AXI-Lite Register Interface
         axilReadMaster  => axilReadMasters(IPMC_INDEX_C),
         axilReadSlave   => axilReadSlaves(IPMC_INDEX_C),
         axilWriteMaster => axilWriteMasters(IPMC_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(IPMC_INDEX_C),
         -- Clocks and Resets
         axilClk         => axilClk,
         axilRst         => axilRst);

   NOT_SIM : if (SIMULATION_G = false) generate

      U_Iprog : entity work.Iprog
         generic map (
            TPD_G        => TPD_G,
            XIL_DEVICE_G => XIL_DEVICE_C)
         port map (
            clk         => axilClk,
            rst         => axilRst,
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
            axilReadMaster  => axilReadMasters(SYSMON_INDEX_C),
            axilReadSlave   => axilReadSlaves(SYSMON_INDEX_C),
            axilWriteMaster => axilWriteMasters(SYSMON_INDEX_C),
            axilWriteSlave  => axilWriteSlaves(SYSMON_INDEX_C),
            -- Clocks and Resets
            axilClk         => axilClk,
            axilRst         => axilRst);

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
            axiReadMaster  => axilReadMasters(BOOT_MEM_INDEX_C),
            axiReadSlave   => axilReadSlaves(BOOT_MEM_INDEX_C),
            axiWriteMaster => axilWriteMasters(BOOT_MEM_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(BOOT_MEM_INDEX_C),
            -- Clocks and Resets
            axiClk         => axilClk,
            axiRst         => axilRst);

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

      axilRstL <= not(axilRst);  -- IPMC uses DONE to determine if FPGA is ready
      do       <= "111" & bootMosi;
      bootMiso <= di(1);

      GEN_SFP :
      for i in 3 downto 0 generate
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
               axiReadMaster  => axilReadMasters(SFP_I2C_INDEX_C+i),
               axiReadSlave   => axilReadSlaves(SFP_I2C_INDEX_C+i),
               axiWriteMaster => axilWriteMasters(SFP_I2C_INDEX_C+i),
               axiWriteSlave  => axilWriteSlaves(SFP_I2C_INDEX_C+i),
               -- Clocks and Resets
               axiClk         => axilClk,
               axiRst         => axilRst);
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
               axiReadMaster  => axilReadMasters(QSFP_I2C_INDEX_C+i),
               axiReadSlave   => axilReadSlaves(QSFP_I2C_INDEX_C+i),
               axiWriteMaster => axilWriteMasters(QSFP_I2C_INDEX_C+i),
               axiWriteSlave  => axilWriteSlaves(QSFP_I2C_INDEX_C+i),
               -- Clocks and Resets
               axiClk         => axilClk,
               axiRst         => axilRst);
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
            axiReadMaster  => axilReadMasters(FP_I2C_INDEX_C),
            axiReadSlave   => axilReadSlaves(FP_I2C_INDEX_C),
            axiWriteMaster => axilWriteMasters(FP_I2C_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(FP_I2C_INDEX_C),
            -- Clocks and Resets
            axiClk         => axilClk,
            axiRst         => axilRst);

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
            axiReadMaster  => axilReadMasters(PLL_I2C_INDEX_C),
            axiReadSlave   => axilReadSlaves(PLL_I2C_INDEX_C),
            axiWriteMaster => axilWriteMasters(PLL_I2C_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(PLL_I2C_INDEX_C),
            -- Clocks and Resets
            axiClk         => axilClk,
            axiRst         => axilRst);

   end generate;

end mapping;
