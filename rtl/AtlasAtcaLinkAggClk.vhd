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

   signal CLKOUT0 : sl;
   signal CLKOUT1 : sl;
   signal clkFb   : sl;
   signal locked  : sl;


   signal axilClock : sl;
   signal axilReset : sl;

   signal eth125Clock : sl;
   signal eth125Reset : sl;

   signal eth62Clock : sl;
   signal eth62Reset : sl;

begin

   ref156Clk <= fabClock;
   ref156Rst <= fabReset;

   axilClk <= axilClock;
   axilRst <= axilReset;

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

   ----------------
   -- Clock Manager
   ----------------
   GEN_REAL : if (SIMULATION_G = false) generate
      U_PLL : PLLE3_BASE
         generic map(
            CLKIN_PERIOD   => 6.4,
            DIVCLK_DIVIDE  => 1,
            CLKFBOUT_MULT  => 8,        -- 1.25GHz
            CLKOUT0_DIVIDE => 8,        -- 156.25 MHz
            CLKOUT1_DIVIDE => 10)       -- 125 MHz
         port map (
            CLKIN       => fabClock,    -- 125 MHz
            RST         => fabReset,
            PWRDWN      => '0',
            CLKOUTPHYEN => '0',
            CLKFBIN     => clkFb,
            CLKFBOUT    => clkFb,
            CLKOUT0     => CLKOUT0,
            CLKOUT1     => CLKOUT1,
            LOCKED      => locked);
   end generate GEN_REAL;

   GEN_SIM : if (SIMULATION_G = true) generate

      U_Clk156 : entity work.ClkRst
         generic map (
            CLK_PERIOD_G      => 6.4 ns,
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => CLKOUT0,
            rstL => locked);

      U_Clk125 : entity work.ClkRst
         generic map (
            CLK_PERIOD_G      => 8.0 ns,
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => CLKOUT1);

   end generate GEN_SIM;

   -------------------
   -- 156.25 MHz Clock
   -------------------
   U_axilClk : BUFG
      port map (
         I => CLKOUT0,
         O => axilClock);

   U_axilRst : entity work.RstSync
      generic map (
         TPD_G         => TPD_G,
         IN_POLARITY_G => '0')
      port map (
         clk      => axilClock,
         asyncRst => locked,
         syncRst  => axilReset);

   ----------------
   -- 125 MHz Clock
   ----------------
   U_eth125Clk : BUFG
      port map (
         I => CLKOUT1,
         O => eth125Clock);

   U_eth125Rst : entity work.RstSync
      generic map (
         TPD_G         => TPD_G,
         IN_POLARITY_G => '0')
      port map (
         clk      => eth125Clock,
         asyncRst => locked,
         syncRst  => eth125Reset);

   ----------------
   -- 62.5 MHz Clock
   ----------------   
   U_eth62Clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 2)
      port map (
         I   => CLKOUT1,
         CE  => '1',
         CLR => eth125Reset,
         O   => eth62Clock);

   U_eth62Rst : entity work.RstSync
      generic map (
         TPD_G         => TPD_G,
         IN_POLARITY_G => '0')
      port map (
         clk      => eth62Clock,
         asyncRst => locked,
         syncRst  => eth62Reset);

end mapping;
