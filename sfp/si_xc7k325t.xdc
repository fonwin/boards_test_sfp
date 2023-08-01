#######################################
#
# si_xc7k325t.xdc
#
#######################################
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

#######################################################################
########## delay system reset ##########
  set_false_path -from [get_pins  sys_ctrl_inst/delay_rst_d*/C]

#######################################################################
########## CLOCK CONSTRAINTS FOR the BOARD ##########
  set_property PACKAGE_PIN AB11    [get_ports clk_200M_p]
  set_property IOSTANDARD  LVDS    [get_ports clk_200M_p]

#######################################################################
########## ------------------ SFP A B ------------------- ##########
# ----- 156.25M for SFP.
  set_property PACKAGE_PIN D6      [get_ports  sfp_gt_refclk_p]
  create_clock -period 6.4         [get_ports  sfp_gt_refclk_p]
# -----
  set_property PACKAGE_PIN H2      [get_ports {sfp_tx_p[0]}]
  set_property PACKAGE_PIN K2      [get_ports {sfp_tx_p[1]}]

############ LED CONSTRAINTS FOR the BOARD ##############
  # ----- SFP用的 4 個 leds;
  set_property PACKAGE_PIN AA2     [get_ports sleds[0]]
  set_property PACKAGE_PIN AD5     [get_ports sleds[1]]
  set_property PACKAGE_PIN W10     [get_ports sleds[2]]
  set_property PACKAGE_PIN Y10     [get_ports sleds[3]]
  set_property IOSTANDARD LVCMOS15 [get_ports sleds[*]]
  set_false_path -to               [get_ports sleds[*]]
#######################################################################
