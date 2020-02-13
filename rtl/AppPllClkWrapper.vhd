-------------------------------------------------------------------------------
-- File       : AppPllClkWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for PLL/FPGA clocks
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

library surf;
use surf.StdRtlPkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AppPllClkWrapper is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Jitter Cleaner PLL Interface
      extRst        : in  sl;
      fpgaToPllClk  : in  sl;
      pllToFpgaClk  : out slv(2 downto 0);
      pllToFpgaRst  : out slv(2 downto 0);
      -- Jitter Cleaner PLL Ports
      fpgaToPllClkP : out sl;
      fpgaToPllClkN : out sl;
      pllToFpgaClkP : in  slv(2 downto 0);
      pllToFpgaClkN : in  slv(2 downto 0));
end entity AppPllClkWrapper;

architecture mapping of AppPllClkWrapper is

   signal refClock       : slv(2 downto 0);
   signal pllToFpgaClock : slv(2 downto 0);

begin

   U_fpgaToPllClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => fpgaToPllClk,
         clkOutP => fpgaToPllClkP,
         clkOutN => fpgaToPllClkN);

   U_IBUFDS_ref160Clk : IBUFDS
      port map (
         I  => pllToFpgaClkP(0),
         IB => pllToFpgaClkN(0),
         O  => refClock(0));

   U_BUFG_ref160Clk : BUFG
      port map (
         I => refClock(0),
         O => pllToFpgaClock(0));

   GEN_CLK :
   for i in 2 downto 1 generate

      U_IBUFDS_GTE4 : IBUFDS_GTE4
         generic map (
            REFCLK_EN_TX_PATH  => '0',
            REFCLK_HROW_CK_SEL => "00",  -- 2'b00: ODIV2 = O
            REFCLK_ICNTL_RX    => "00")
         port map (
            I     => pllToFpgaClkP(i),
            IB    => pllToFpgaClkN(i),
            CEB   => '0',
            ODIV2 => refClock(i),
            O     => open);

      U_BUFG_GT : BUFG_GT
         port map (
            I       => refClock(i),
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",
            O       => pllToFpgaClock(i));

   end generate GEN_CLK;

   GEN_RST :
   for i in 2 downto 0 generate

      U_ref160Rst : entity surf.RstPipeline
         generic map (
            TPD_G => TPD_G)
         port map (
            clk    => pllToFpgaClock(i),
            rstIn  => extRst,
            rstOut => pllToFpgaRst(i));

   end generate GEN_RST;

   pllToFpgaClk <= pllToFpgaClock;

end architecture mapping;
