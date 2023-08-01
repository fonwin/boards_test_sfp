`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module signal_counter #(
  parameter COUNTER_WIDTH = 16,
  parameter SIGNAL_INIT   = 0,
  // 1=posedge; 0=negedge;
  parameter COUNT_POSEDGE = 1
)
(
  input  wire                    clk,
  input  wire                    rst,
  input  wire                    signal_in,
  output reg [COUNTER_WIDTH-1:0] counter_out = 0
);
reg signal_bf = SIGNAL_INIT;
always @(posedge clk) begin
  if (signal_in != signal_bf) begin
    counter_out <= counter_out + (COUNT_POSEDGE ? signal_in : signal_bf);
  end
  signal_bf <= signal_in;
  if (rst) begin
    counter_out <= 0;
    signal_bf   <= SIGNAL_INIT;
  end
end
endmodule
//////////////////////////////////////////////////////////////////////////////////
