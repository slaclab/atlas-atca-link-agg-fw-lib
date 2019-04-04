-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggRegPkg.vhd
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
use work.AxiLitePkg.all;
use work.I2cPkg.all;
use work.AtlasAtcaLinkAggPkg.all;

package AtlasAtcaLinkAggRegPkg is

   -- FSBL Timeout Duration
   constant TIMEOUT_C : integer := integer(10.0 / AXIL_CLK_PERIOD_C);

   constant NUM_AXIL_MASTERS_C : NaturalArray(1 downto 0) := (
      0 => 4,
      1 => 13);

   constant BASE_INDEX_C    : natural := 0;
   constant PLL_SPI_INDEX_C : natural := 1;
   constant ETH_INDEX_C     : natural := 2;
   constant APP_INDEX_C     : natural := 3;

   constant XBAR_CONFIG_0_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C(0)-1 downto 0) := (
      BASE_INDEX_C    => (
         baseAddr     => x"0000_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      PLL_SPI_INDEX_C => (
         baseAddr     => x"0001_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      ETH_INDEX_C     => (
         baseAddr     => x"0100_0000",
         addrBits     => 24,
         connectivity => x"FFFF"),
      APP_INDEX_C     => (
         baseAddr     => APP_AXIL_BASE_ADDR_C,
         addrBits     => 31,
         connectivity => x"FFFF"));

   constant VERSION_INDEX_C  : natural := 0;
   constant SYSMON_INDEX_C   : natural := 1;
   constant BOOT_MEM_INDEX_C : natural := 2;
   constant IPMC_INDEX_C     : natural := 3;
   constant SFP_I2C_INDEX_C  : natural := 4;  -- [4:8]
   constant QSFP_I2C_INDEX_C : natural := 9;  -- [9:10]
   constant FP_I2C_INDEX_C   : natural := 11;
   constant PLL_I2C_INDEX_C  : natural := 12;

   constant XBAR_CONFIG_1_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C(1)-1 downto 0) := (
      VERSION_INDEX_C    => (
         baseAddr        => x"0000_0000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      SYSMON_INDEX_C     => (
         baseAddr        => x"0000_1000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      BOOT_MEM_INDEX_C   => (
         baseAddr        => x"0000_2000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      IPMC_INDEX_C       => (
         baseAddr        => x"0000_3000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      SFP_I2C_INDEX_C+0  => (
         baseAddr        => x"0000_4000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      SFP_I2C_INDEX_C+1  => (
         baseAddr        => x"0000_5000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      SFP_I2C_INDEX_C+2  => (
         baseAddr        => x"0000_6000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      SFP_I2C_INDEX_C+3  => (
         baseAddr        => x"0000_7000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      SFP_I2C_INDEX_C+4  => (
         baseAddr        => x"0000_8000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      QSFP_I2C_INDEX_C+0 => (
         baseAddr        => x"0000_9000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      QSFP_I2C_INDEX_C+1 => (
         baseAddr        => x"0000_A000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      FP_I2C_INDEX_C     => (
         baseAddr        => x"0000_B000",
         addrBits        => 12,
         connectivity    => x"FFFF"),
      PLL_I2C_INDEX_C    => (
         baseAddr        => x"0000_C000",
         addrBits        => 12,
         connectivity    => x"FFFF"));

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

end package AtlasAtcaLinkAggRegPkg;
