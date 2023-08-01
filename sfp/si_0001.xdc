#######################################
#
# si_0001.xdc
#
#######################################
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

#######################################################################
########## delay system reset ##########
  set_false_path -from [get_pins  sys_ctrl_inst/delay_rst_d*/C]

#######################################################################
########## CLOCK CONSTRAINTS FOR the BOARD ##########
  set_property PACKAGE_PIN F17      [get_ports clk_100M]
  set_property IOSTANDARD  LVCMOS33 [get_ports clk_100M]

#######################################################################
########## ------------------ SFP A B ------------------- ##########
# ----- 156.25M for SFP.
  set_property PACKAGE_PIN D6      [get_ports  sfp_gt_refclk_p]
  create_clock -period 6.4         [get_ports  sfp_gt_refclk_p]
# -----
  set_property PACKAGE_PIN K2      [get_ports {sfp_tx_p[0]}]

############ LED CONSTRAINTS FOR the BOARD ##############
  # ----- SFP用的 leds;
  set_property PACKAGE_PIN AF22    [get_ports sleds[0]]
  set_property PACKAGE_PIN AE22    [get_ports sleds[1]]
  set_property IOSTANDARD LVCMOS33 [get_ports sleds[*]]
  set_false_path -to               [get_ports sleds[*]]
#######################################################################
