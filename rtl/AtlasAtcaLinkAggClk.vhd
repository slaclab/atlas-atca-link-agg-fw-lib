-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggClk.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Clock Wrapper
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

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggClk is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      axilClk       : out sl;
      axilRst       : out sl;
      ref156Clk     : out sl;
      ref156Rst     : out sl;
      eth125Clk     : out sl;
      eth125Rst     : out sl;
      eth62Clk      : out sl;
      eth62Rst      : out sl;
      fabEthRefClkP : in  sl;
      fabEthRefClkN : in  sl;
      fabEthRefClk  : out sl);
end AtlasAtcaLinkAggClk;

architecture mapping of AtlasAtcaLinkAggClk is

   signal fabRefClk : sl;
   signal fabClock  : sl;
   signal fabReset  : sl;

   signal axilClock : sl;
   signal axilReset : sl;

   signal eth125Clock : sl;
   signal eth125Reset : sl;

   signal eth62Clock : sl;
   signal eth62Reset : sl;

begin

   axilClk <= axilClock;
   axilRst <= axilReset;

   ref156Clk <= fabClock;
   ref156Rst <= fabReset;

   eth125Clk <= eth125Clock;
   eth125Rst <= eth125Reset;

   eth62Clk <= eth62Clock;
   eth62Rst <= eth62Reset;

   --------------------------------
   -- Common Clock and Reset Module
   -------------------------------- 
   U_IBUFDS_GT : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => fabEthRefClkP,
         IB    => fabEthRefClkN,
         CEB   => '0',
         ODIV2 => fabRefClk,
         O     => fabEthRefClk);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => fabRefClk,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",              -- Divide by 1
         O       => fabClock);

   U_PwrUpRst : entity work.PwrUpRst
      generic map(
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => SIMULATION_G)
      port map(
         clk    => fabClock,
         rstOut => fabReset);

   U_Pll : entity work.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         SIMULATION_G      => SIMULATION_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 2,
         -- MMCM attributes
         BANDWIDTH_G       => "OPTIMIZED",
         CLKIN_PERIOD_G    => 6.4,      -- 156.25 MHz
         CLKFBOUT_MULT_G   => 8,        -- 1.25GHz=156.25 MHz*8
         CLKOUT0_DIVIDE_G  => 8,        -- 156.25MHz=1.25GHz/8
         CLKOUT1_DIVIDE_G  => 10)       -- 125MHz=1.25GHz/10
      port map(
         -- Clock Input
         clkIn     => fabClock,
         rstIn     => fabReset,
         -- Clock Outputs
         clkOut(0) => axilClock,
         clkOut(1) => eth125Clock,
         -- Reset Outputs
         rstOut(0) => axilReset,
         rstOut(1) => eth125Reset);

   U_eth62Clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 2)
      port map (
         I   => eth125Clock,
         CE  => '1',
         CLR => eth125Reset,
         O   => eth62Clock);

   U_eth62Rst : entity work.RstSync
      generic map (
         TPD_G => TPD_G)
      port map (
         clk      => eth62Clock,
         asyncRst => eth125Reset,
         syncRst  => eth62Reset);

end mapping;
