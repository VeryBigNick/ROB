## Generated SDC file "ROB.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Intel Corporation"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 222 09/21/2018 SJ Pro Edition"

## DATE    "Tue Mar 31 10:48:38 2020"

##
## DEVICE  "10AS016E3F29I1SG"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {pin_clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {pin_clk}]
create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 }  [get_pins {u0|iopll_0|altera_iopll_i|twentynm_pll|iopll_inst|outclk[0]}]

#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {pin_clk}] -rise_to [get_clocks {pin_clk}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {pin_clk}] -fall_to [get_clocks {pin_clk}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {pin_clk}] -rise_to [get_clocks {pin_clk}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {pin_clk}] -fall_to [get_clocks {pin_clk}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {pin_clk}]  0.190  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {pin_clk}]  0.190  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {pin_clk}]  0.190  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {pin_clk}]  0.190  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {mem_rsp_ID[*]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {mem_rsp_data[*]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {mem_rsp_val}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {req_ID[*]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {req_addr[*]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {req_param[*]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {req_val}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {rsp_ready}]


#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {mem_req_ID[*]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {mem_req_addr[*]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {mem_req_val}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {rsp_val}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {rsp_ID[*]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {rsp_param[*]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {rsp_data[*]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {req_ready}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

