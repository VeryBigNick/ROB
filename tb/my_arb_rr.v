`ifndef _MY_ARB_RR__V_
`define _MY_ARB_RR__V_


module my_arb_rr
#(
    parameter       REQ_NUM         = -1,
    parameter       REQ_NUM_WIDTH   = -1
)
(
    input   wire    [REQ_NUM        - 1:0]      requests,    
    input   wire    [REQ_NUM_WIDTH  - 1:0]      priority_pnt,

    output  wire    [REQ_NUM        - 1:0]      grant        
);

genvar                          Gi, Gj;

//-----------------------------------------------------------------------------------------------//
wire    [REQ_NUM_WIDTH  - 1:0]      priority_list       [REQ_NUM - 1:0];
wire    [REQ_NUM        - 1:0]      filter_matrix       [REQ_NUM - 1:0];

localparam REQ_NUM_MINUS_ONE = REQ_NUM - 1;

generate
if (1) begin: gen_priority_list
    for (Gi = 0; Gi < REQ_NUM; Gi = Gi + 1) begin: request
        assign
            priority_list[Gi] = REQ_NUM_MINUS_ONE[REQ_NUM_WIDTH - 1:0] - Gi[REQ_NUM_WIDTH - 1:0] + priority_pnt;
    end
end
endgenerate

generate
if (1) begin: filter
    for (Gi = 0; Gi < REQ_NUM; Gi = Gi + 1) begin: request_prim
        for (Gj = 0; Gj < REQ_NUM; Gj = Gj + 1) begin: request_sec
            if (Gj == Gi) begin: request_same
                assign
                    filter_matrix[Gi][Gj] = 1'b0;
            end
            else begin: cell_other
                assign
                    filter_matrix[Gi][Gj] = requests[Gi] & requests[Gj] & (priority_list[Gi] < priority_list[Gj]);
            end
        end
    end
end
endgenerate

generate
if (1) begin: filter_out
    for (Gi = 0; Gi < REQ_NUM; Gi = Gi + 1) begin: request
        assign
            grant[Gi] = ~(|filter_matrix[Gi]) & requests[Gi];
    end
end
endgenerate


endmodule

`endif
