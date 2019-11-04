source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2018.3 of Vivado (or later)
if { [VersionCheck 2018.3] < 0 } {exit -1}

loadSource -dir "$::DIR_PATH/rtl"

loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggCorePorts.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggAppPorts.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggTiming.xdc"

loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"
loadIpCore -path "$::DIR_PATH/ip/LvdsSgmiiEthPhy.xci"

loadConstraints -path "$::DIR_PATH/ip/LvdsSgmiiEthPhy_clocks.xdc"
set_property PROCESSING_ORDER {EARLY}           [get_files {LvdsSgmiiEthPhy_clocks.xdc}]
set_property SCOPED_TO_REF    {LvdsSgmiiEthPhy} [get_files {LvdsSgmiiEthPhy_clocks.xdc}]
set_property SCOPED_TO_CELLS  {inst}            [get_files {LvdsSgmiiEthPhy_clocks.xdc}]

loadConstraints -path "$::DIR_PATH/ip/LvdsSgmiiEthPhy.xdc"
set_property PROCESSING_ORDER {LATE}            [get_files {LvdsSgmiiEthPhy.xdc}]
set_property SCOPED_TO_REF    {LvdsSgmiiEthPhy} [get_files {LvdsSgmiiEthPhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}            [get_files {LvdsSgmiiEthPhy.xdc}]

# Adding the common Si5345 configuration
add_files -norecurse "$::DIR_PATH/pll-config/AtlasAtcaLinkAggDefaultPllConfig.mem"