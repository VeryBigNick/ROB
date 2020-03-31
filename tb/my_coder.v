`ifndef     _MY_CODER__V_

`define     _MY_CODER__V_   1

module	my_coder	#(
parameter	N = 4,
			PTR = 2
)(
input	[N - 1:0]	in,
output	[PTR - 1:0]	out,
output              multi_in
); 

genvar	Gi, Gj;

wire	[PTR - 1:0]	out_Gi	[N - 1:0];
wire	[N - 1:0]	out_i_j	[PTR - 1:0];


generate
	for ( Gi = 0; Gi < N; Gi = Gi + 1 )	begin: Gi_block
		assign	out_Gi[Gi] = Gi;	end
	for ( Gi = 0; Gi < PTR; Gi = Gi + 1 )	begin: i_block
		for ( Gj = 0; Gj < N; Gj = Gj + 1 )	begin: j_block
			assign	out_i_j[Gi][Gj] = in[Gj] & out_Gi[Gj][Gi];
		end
			assign	out[Gi] = |out_i_j[Gi];
	end
endgenerate

wire    [N - 1:0]   multi_in_decode;

generate
    for ( Gi = 0; Gi < N; Gi = Gi + 1 ) begin: multi_in_decode_blk
        assign  multi_in_decode[Gi] = in[Gi] & ( out != Gi );
    end
endgenerate

assign  multi_in = |multi_in_decode;


endmodule

`endif