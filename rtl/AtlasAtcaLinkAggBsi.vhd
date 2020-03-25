-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggBsi.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: BootStrap Interface (BSI) to the IPMI's controller (IPMC) 
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
use surf.i2cPkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggBsi is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Local Configuration
      bsiBus          : out   BsiBusType;
      localIp         : out   Slv32Array(NUM_ETH_C-1 downto 0);
      ethLinkUp       : in    slv(NUM_ETH_C-1 downto 0);
      bootReq         : out   sl;
      bootAddr        : out   slv(31 downto 0);
      upTimeCnt       : in    slv(31 downto 0);
      ledRedL         : out   slv(1 downto 0);
      ledBlueL        : out   slv(1 downto 0);
      ledGreenL       : out   slv(1 downto 0);
      -- I2C Ports
      scl             : inout sl;
      sda             : inout sl;
      -- AXI-Lite Register Interface
      axilReadMaster  : in    AxiLiteReadMasterType;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- Clocks and Resets
      axilClk         : in    sl;
      axilRst         : in    sl);
end AtlasAtcaLinkAggBsi;

architecture rtl of AtlasAtcaLinkAggBsi is

   constant BUILD_INFO_C : BuildInfoRetType := toBuildInfo(BUILD_INFO_G);

   constant BSI_MAJOR_VERSION_C : slv(7 downto 0) := x"01";
   constant BSI_MINOR_VERSION_C : slv(7 downto 0) := x"03";

   constant TIMEOUT_1HZ_C : natural := (getTimeRatio(1.0, AXIL_CLK_PERIOD_C) -1);

   type TimerArray is array (natural range <>) of natural range 0 to TIMEOUT_1HZ_C;

   type RomType is array (0 to 255) of slv(7 downto 0);

   function makeStringRom return RomType is
      variable ret : RomType := (others => (others => '0'));
   begin
      ret(0) := x"00";
      for i in 0 to 254 loop
         ret(i+1) := BUILD_INFO_C.buildString(i/4)(8*(i mod 4)+7 downto 8*(i mod 4));
      end loop;
      return ret;
   end function makeStringRom;

   signal stringRom : RomType := makeStringRom;

   type RegType is record
      ledRed         : slv(1 downto 0);
      ledBlue        : slv(1 downto 0);
      ledGreen       : slv(1 downto 0);
      ethUpTimeCnt   : Slv32Array(NUM_ETH_C-1 downto 0);
      timer          : TimerArray(NUM_ETH_C-1 downto 0);
      cnt            : slv(3 downto 0);
      addr           : slv(7 downto 0);
      we             : sl;
      ramData        : slv(7 downto 0);
      bootReq        : sl;
      bootAddr       : slv(31 downto 0);
      slotNumber     : slv(7 downto 0);
      crateId        : slv(15 downto 0);
      macAddress     : Slv48Array(NUM_ETH_C-1 downto 0);
      localIp        : Slv32Array(NUM_ETH_C-1 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      ledRed         => "00",
      ledBlue        => "00",
      ledGreen       => "00",
      ethUpTimeCnt   => (others => (others => '0')),
      timer          => (others => 0),
      cnt            => x"0",
      addr           => x"00",
      we             => '0',
      ramData        => x"00",
      bootReq        => '0',
      bootAddr       => x"04000000",    -- Default to 2nd stage boot 
      slotNumber     => x"00",
      crateId        => x"0000",
      macAddress     => (others => (others => '0')),
      localIp        => (others => x"0000_000A"),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal i2cBramWr   : slv(1 downto 0);
   signal i2cBramAddr : Slv8Array(1 downto 0);
   signal i2cBramDout : Slv8Array(1 downto 0);
   signal i2cBramDin  : Slv8Array(1 downto 0);
   signal bramDout    : slv(7 downto 0);
   signal ramData     : slv(7 downto 0);
   signal slaveIn     : i2c_in_array(1 downto 0);
   signal slaveOut    : i2c_out_array(1 downto 0);
   signal i2cIn       : i2c_in_type;
   signal i2cOut      : i2c_out_type;
   signal macRdy      : sl;

begin

   U_I2cScl : IOBUF
      port map (
         IO => scl,
         I  => i2cOut.scl,
         O  => i2cIn.scl,
         T  => i2cOut.scloen);

   U_I2cSda : IOBUF
      port map (
         IO => sda,
         I  => i2cOut.sda,
         O  => i2cIn.sda,
         T  => i2cOut.sdaoen);

   -------------------------
   -- MUX I2C Slave together
   -------------------------
   slaveIn(0).scl <= i2cIn.scl;
   slaveIn(1).scl <= i2cIn.scl;
   slaveIn(0).sda <= i2cIn.sda;
   slaveIn(1).sda <= i2cIn.sda;

   i2cOut.scl    <= '0';
   i2cOut.scloen <= slaveOut(0).scloen and slaveOut(1).scloen;
   i2cOut.sda    <= '0';
   i2cOut.sdaoen <= slaveOut(0).sdaoen and slaveOut(1).sdaoen;

   -------------------
   -- I2c Slave @ 0x49
   -------------------
   U_I2C_SLAVE_0x49 : entity surf.i2cRegSlave
      generic map (
         TPD_G                => TPD_G,
         TENBIT_G             => 0,
         I2C_ADDR_G           => 73,    -- "1001001";
         OUTPUT_EN_POLARITY_G => 0,
         FILTER_G             => 4,
         ADDR_SIZE_G          => 1,     -- in bytes
         DATA_SIZE_G          => 1,     -- in bytes
         ENDIANNESS_G         => 1)     -- 0=LE, 1=BE
      port map (
         clk    => axilClk,
         sRst   => axilRst,
         aRst   => '0',
         addr   => i2cBramAddr(0),
         wrEn   => i2cBramWr(0),
         wrData => i2cBramDin(0),
         rdEn   => open,
         rdData => i2cBramDout(0),
         i2ci   => slaveIn(0),
         i2co   => slaveOut(0));

   -------------------
   -- I2c Slave @ 0x51
   -------------------
   U_I2C_SLAVE_0x51 : entity surf.i2cRegSlave
      generic map (
         TPD_G                => TPD_G,
         TENBIT_G             => 0,
         I2C_ADDR_G           => 81,    -- "1010001";
         OUTPUT_EN_POLARITY_G => 0,
         FILTER_G             => 4,
         ADDR_SIZE_G          => 1,     -- in bytes
         DATA_SIZE_G          => 1,     -- in bytes
         ENDIANNESS_G         => 1)     -- 0=LE, 1=BE
      port map (
         clk    => axilClk,
         sRst   => axilRst,
         aRst   => '0',
         addr   => i2cBramAddr(1),
         wrEn   => i2cBramWr(1),
         wrData => i2cBramDin(1),
         rdEn   => open,
         rdData => i2cBramDout(1),
         i2ci   => slaveIn(1),
         i2co   => slaveOut(1));

   ----------------
   -- Dual port RAM
   ----------------   
   U_RAM : entity surf.TrueDualPortRam
      generic map (
         TPD_G        => TPD_G,
         MODE_G       => "read-first",
         DATA_WIDTH_G => 8,
         ADDR_WIDTH_G => 8)
      port map (
         -- Port A     
         clka  => axilClk,
         wea   => i2cBramWr(0),
         addra => i2cBramAddr(0),
         dina  => i2cBramDin(0),
         douta => i2cBramDout(0),
         -- Port B
         clkb  => axilClk,
         web   => r.we,
         addrb => r.addr,
         dinb  => r.ramData,
         doutb => ramData);

   ------------------
   -- Single port ROM
   ------------------ 
   process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         i2cBramDout(1) <= stringRom(conv_integer(i2cBramAddr(1))) after TPD_G;
      end if;
   end process;

   --------------------- 
   -- AXI Lite Interface
   --------------------- 
   comb : process (axilReadMaster, axilRst, axilWriteMaster, ethLinkUp, macRdy,
                   r, ramData, upTimeCnt) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
      variable i      : natural;
      variable index  : natural;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobe
      v.we := '0';

      -- Increment the counter
      v.cnt := r.cnt + 1;

      -- Update the index
      index := conv_integer(r.addr(7 downto 4));

      -- Check counter phase
      if r.cnt = x"0" then
         -- Increment the address
         v.addr := r.addr + 1;
      elsif r.cnt = x"8" then
         -- Reset the data bus
         v.ramData := x"00";
         -- Check the address bus
         case (r.addr) is
            ---------------------------------------
            -- Check for ATCA slot number
            ---------------------------------------
            when x"FF" => v.slotNumber           := ramData;
            ---------------------------------------
            -- Check for ATCA Crate ID
            ---------------------------------------
            when x"FE" => v.crateId(15 downto 8) := ramData;
            when x"FD" => v.crateId(7 downto 0)  := ramData;
            ---------------------------------------
            -- Check for BSI Version
            ---------------------------------------
            when x"FC" =>
               v.we      := '1';
               v.ramData := BSI_MINOR_VERSION_C;
            when x"FB" =>
               v.we      := '1';
               v.ramData := BSI_MAJOR_VERSION_C;
            ---------------------------------------
            -- Check for start boot
            ---------------------------------------
            when x"FA" =>
               -- Sample the LSB of the memory byte
               v.bootReq := ramData(0);
               -- Reset memory
               v.we      := '1';
               v.ramData := x"00";
            ---------------------------------------
            -- Check for boot address
            ---------------------------------------
            when x"F9" => v.bootAddr(31 downto 24) := ramData;
            when x"F8" => v.bootAddr(23 downto 16) := ramData;
            when x"F7" => v.bootAddr(15 downto 8)  := ramData;
            when x"F6" => v.bootAddr(7 downto 0)   := ramData;
            ---------------------------------------
            -- Check for BUILD_INFO_C.fwVersion
            ---------------------------------------            
            when x"F5" =>
               v.we      := '1';
               v.ramData := BUILD_INFO_C.fwVersion(31 downto 24);
            when x"F4" =>
               v.we      := '1';
               v.ramData := BUILD_INFO_C.fwVersion(23 downto 16);
            when x"F3" =>
               v.we      := '1';
               v.ramData := BUILD_INFO_C.fwVersion(15 downto 8);
            when x"F2" =>
               v.we      := '1';
               v.ramData := BUILD_INFO_C.fwVersion(7 downto 0);
            ---------------------------------------
            -- Check for DDR Memory Status
            ---------------------------------------               
            when x"F1" =>
               v.we         := '1';
               -- v.ramData(0) := ddrMemError;
               v.ramData(0) := '0';
            when x"F0" =>
               v.we                  := '1';
               v.ramData(7 downto 2) := ethLinkUp;
               v.ramData(1)          := uOr(ethLinkUp);
               -- v.ramData(0) := ddrMemReady;
               v.ramData(0)          := '1';
            ----------------------------------------
            -- Check for AxiVersion's Uptime Counter
            ----------------------------------------            
            when x"EF" =>
               v.we      := '1';
               v.ramData := upTimeCnt(31 downto 24);
            when x"EE" =>
               v.we      := '1';
               v.ramData := upTimeCnt(23 downto 16);
            when x"ED" =>
               v.we      := '1';
               v.ramData := upTimeCnt(15 downto 8);
            when x"EC" =>
               v.we      := '1';
               v.ramData := upTimeCnt(7 downto 0);
            --------------------------------------
            -- Check for Ethernet's Uptime Counter
            --------------------------------------            
            when x"EB" =>
               v.we      := '1';
               v.ramData := r.ethUpTimeCnt(0)(31 downto 24);
            when x"EA" =>
               v.we      := '1';
               v.ramData := r.ethUpTimeCnt(0)(23 downto 16);
            when x"E9" =>
               v.we      := '1';
               v.ramData := r.ethUpTimeCnt(0)(15 downto 8);
            when x"E8" =>
               v.we      := '1';
               v.ramData := r.ethUpTimeCnt(0)(7 downto 0);
            -------------------
            -- Get the GIT HASH
            -------------------
            when x"D0" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(7 downto 0);
            when x"D1" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(15 downto 8);
            when x"D2" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(23 downto 16);
            when x"D3" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(31 downto 24);
            when x"D4" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(39 downto 32);
            when x"D5" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(47 downto 40);
            when x"D6" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(55 downto 48);
            when x"D7" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(63 downto 56);
            when x"D8" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(71 downto 64);
            when x"D9" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(79 downto 72);
            when x"DA" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(87 downto 80);
            when x"DB" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(95 downto 88);
            when x"DC" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(103 downto 96);
            when x"DD" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(111 downto 104);
            when x"DE" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(119 downto 112);
            when x"DF" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(127 downto 120);
            when x"E0" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(135 downto 128);
            when x"E1" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(143 downto 136);
            when x"E2" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(151 downto 144);
            when x"E3" => v.we := '1'; v.ramData := BUILD_INFO_C.gitHash(159 downto 152);
            ---------------------------------------
            when others =>
               if (index < 4) then
                  -- Check for available MAC addresses
                  case (r.addr(3 downto 0)) is
                     when x"0"   => v.macAddress(index)(7 downto 0)   := ramData;
                     when x"1"   => v.macAddress(index)(15 downto 8)  := ramData;
                     when x"2"   => v.macAddress(index)(23 downto 16) := ramData;
                     when x"3"   => v.macAddress(index)(31 downto 24) := ramData;
                     when x"4"   => v.macAddress(index)(39 downto 32) := ramData;
                     when x"5"   => v.macAddress(index)(47 downto 40) := ramData;
                     when others => null;
                  end case;
               end if;
         end case;
      end if;

      -- Update the local IP addresses
      for i in NUM_ETH_C-1 downto 0 loop
         v.localIp(i)(15 downto 8)  := r.crateId(15 downto 8);
         v.localIp(i)(23 downto 16) := r.crateId(7 downto 0);
         v.localIp(i)(31 downto 24) := (100 + 16*i + r.slotNumber);
      end loop;

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      for i in NUM_ETH_C-1 downto 0 loop
         axiSlaveRegisterR(regCon, toSlv(8*i, 8), 0, endianSwap(r.macAddress(i)));
         axiSlaveRegisterR(regCon, toSlv(4*i+64, 8), 0, r.ethUpTimeCnt(i));
      end loop;
      axiSlaveRegisterR(regCon, x"80", 0, r.crateId);
      axiSlaveRegisterR(regCon, x"84", 0, r.slotNumber);
      axiSlaveRegisterR(regCon, x"88", 0, r.bootAddr);
      axiSlaveRegisterR(regCon, x"8C", 0, BSI_MINOR_VERSION_C);
      axiSlaveRegisterR(regCon, x"90", 8, BSI_MAJOR_VERSION_C);
      axiSlaveRegisterR(regCon, x"90", 16, ethLinkUp);

      axiSlaveRegister (regCon, x"94", 0, v.ledRed);
      axiSlaveRegister (regCon, x"94", 8, v.ledBlue);
      axiSlaveRegister (regCon, x"94", 16, v.ledGreen);

      -- Closeout the transaction
      axiSlaveDefault(regCon, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      --------------------------
      -- Ethernet Uptime counter
      --------------------------
      for i in NUM_ETH_C-1 downto 0 loop
         if ethLinkUp(i) = '0' then
            v.timer(i)        := 0;
            v.ethUpTimeCnt(i) := (others => '0');
         elsif r.timer(i) = TIMEOUT_1HZ_C then
            v.timer(i)        := 0;
            v.ethUpTimeCnt(i) := r.ethUpTimeCnt(i) + 1;
         else
            v.timer(i) := r.timer(i) + 1;
         end if;
      end loop;

      -- Check for non-zero 4th MAC address
      -- Note: 5th and 6th MAC addresses not stored in legacy IPMC code
      if (r.macAddress(3) /= 0) then
         -- Assume the MAC addresses were allocated in sequential order 
         v.macAddress(4) := r.macAddress(3)+1;
         v.macAddress(5) := r.macAddress(3)+2;
      else
         v.macAddress(4) := (others => '0');
         v.macAddress(5) := (others => '0');
      end if;

      -- Synchronous Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      axilWriteSlave    <= r.axilWriteSlave;
      axilReadSlave     <= r.axilReadSlave;
      bootReq           <= r.bootReq;
      bootAddr          <= r.bootAddr;
      bsiBus.slotNumber <= r.slotNumber;
      bsiBus.crateId    <= r.crateId;
      localIp           <= r.localIp;
      for i in NUM_ETH_C-1 downto 0 loop
         if (macRdy = '1') then
            bsiBus.macAddress(i) <= endianSwap(r.macAddress(i));
         else
            bsiBus.macAddress(i) <= (others => '0');
         end if;
      end loop;
      ledRedL   <= not(r.ledRed);
      ledBlueL  <= not(r.ledBlue);
      ledGreenL <= not(r.ledGreen);

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_macRdy : entity surf.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '0',
         DURATION_G     => (5*156250000))  -- 5 seconds
      port map(
         arst   => axilRst,
         clk    => axilClk,
         rstOut => macRdy);

end rtl;
