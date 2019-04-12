source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

loadSource -dir "$::DIR_PATH/rtl"

loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggCorePorts.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggAppPorts.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AtlasAtcaLinkAggTiming.xdc"
   
loadSource -path "$::DIR_PATH/ip/SysMonCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"
