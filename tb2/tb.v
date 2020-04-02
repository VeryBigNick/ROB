module tb;

localparam ROB_SIZE  = 128,
           SWIDTH    = 4 ,
           AWIDTH    = 32,
           DWIDTH    = 32,
           PWIDTH    = 10,
           IDWIDTH   = 16;

reg   clk;
reg   rst_;

reg                    req_val;
reg   [AWIDTH  - 1:0]  req_addr;
reg   [IDWIDTH - 1:0]  req_ID;
reg   [PWIDTH  - 1:0]  req_param;
wire                   req_ready;

wire                   rsp_val;
wire  [DWIDTH  - 1:0]  rsp_data;
wire  [IDWIDTH - 1:0]  rsp_ID;
wire  [PWIDTH  - 1:0]  rsp_param;
reg                    rsp_ready = 1;

wire                   mem_req_val;
wire  [AWIDTH  - 1:0]  mem_req_addr;
wire  [SWIDTH  - 1:0]  mem_req_ID;

reg                    mem_rsp_val;
reg   [SWIDTH  - 1:0]  mem_rsp_ID;
reg   [DWIDTH  - 1:0]  mem_rsp_data;

ROB
# (
  .ROB_SIZE ( ROB_SIZE ),
  .SWIDTH   ( SWIDTH   ),
  .AWIDTH   ( AWIDTH   ),
  .DWIDTH   ( DWIDTH   ),
  .PWIDTH   ( PWIDTH   ),
  .IDWIDTH  ( IDWIDTH  )
)
rob (.*);

initial
begin
  clk = 1'b0;

  forever
    #10 clk = ! clk;
end

localparam n = 10;

reg [n - 1:0] reqs;

initial
begin
  `ifdef XCELIUM
  $recordfile ("cadence.trn");
  $recordvars ();
  `endif

  req_val     <= 1'b0;
  mem_rsp_val <= 1'b0;

  rst_ <= 1'b0;
  repeat (10) @ (posedge clk);
  rst_ <= 1'b1;
  repeat (10) @ (posedge clk);

  fork
  begin
    // start bunch of requests

    req_val <= 1'b1;

    for (int i = 0; i < n; i ++)
    begin
      req_addr  <= i;
      req_ID    <= i;
      req_param <= i;

      @ (posedge clk);
    end

    req_val <= 1'b0;
  end
  begin
    // wait for all memory requests

    reqs = '0;

    while (reqs != { n { 1'b1 } })
    begin
      if (mem_req_val)
        reqs [mem_req_addr % n] = 1'b1;

      @ (posedge clk);
    end
  end
  join

  repeat (20) @ (posedge clk);

  // respond in order

  mem_rsp_val  <= 1'b1;

  for (int i = 0; i < n / 2; i ++)
  begin
    mem_rsp_ID   <= i;
    mem_rsp_data <= i;

    @ (posedge clk);
  end

  mem_rsp_val <= 1'b0;

  repeat (20) @ (posedge clk);

  // respond out of order

  mem_rsp_val  <= 1'b1;

  for (int i = 0; i < n / 2; i ++)
  begin
    mem_rsp_val  <= 1'b1;
    mem_rsp_ID   <= n - 1 - i;
    mem_rsp_data <= n - 1 - i;

    @ (posedge clk);
  end

  mem_rsp_val  <= 1'b0;

  repeat (100) @ (posedge clk);
  $finish;
end

endmodule