module rmem #(
    parameter depth     = 8, 
    parameter awidth    = 3, 
    parameter width     = 34) (
input		wclk,
input		rclk,

input			    wren,
input[awidth-1:0]	waddress,
input[width-1:0]	wdata,

input			    rden,
input[awidth-1:0]	raddress,
output[width-1:0]	rdata
);
reg [width-1:0]	ram_cell [0:depth-1];
reg [awidth-1:0]	raddress_r;
always@(posedge wclk) if (wren) ram_cell[waddress] <= wdata;
always@(posedge rclk) if (rden) raddress_r <= raddress;
assign rdata = ram_cell[raddress_r];
endmodule	
