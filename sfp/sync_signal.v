`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module sync_signal #(
  parameter WIDTH = 1,
  parameter DEPTH = 2
)
(
  input  wire             clk,
  input  wire [WIDTH-1:0] in,
  output wire [WIDTH-1:0] out
);
(* ASYNC_REG = "TRUE" *)
reg [WIDTH-1:0] sync_reg[DEPTH-1:0];
assign    out = sync_reg[DEPTH-1];

integer iL;
always @(posedge clk) begin
  sync_reg[0] <= in;
  for (iL = 1; iL < DEPTH; iL = iL + 1) begin
    sync_reg[iL] <= sync_reg[iL-1];
  end
end
endmodule
//////////////////////////////////////////////////////////////////////////////////
module sync_reset #(
  parameter DEPTH = 2
)
(
  input  wire  clk,
  input  wire  rst_in,
  output wire  rst_out
);
(* ASYNC_REG = "TRUE" *)
(* SRL_STYLE = "register" *)
reg [DEPTH-1:0] sync_reg = {DEPTH{1'b1}};
assign rst_out = sync_reg[DEPTH-1];

always @(posedge clk, posedge rst_in) begin
  if (rst_in) begin
    sync_reg <= {DEPTH{1'b1}};
  end else begin
    sync_reg <= {sync_reg[DEPTH-2:0], 1'b0};
  end
end
endmodule
//////////////////////////////////////////////////////////////////////////////////
