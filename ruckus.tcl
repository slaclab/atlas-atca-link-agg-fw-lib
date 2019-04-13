source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2018.3 of Vivado (or later)
if { [VersionCheck 2018.3] < 0 } {exit -1}

loadSource -dir "$::DIR_PATH/rtl"

loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggCorePorts.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggAppPorts.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggTiming.xdc"
   
loadSource -path "$::DIR_PATH/ip/SysMonCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"
