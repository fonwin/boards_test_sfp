///
///   必須先定義 sysclk_wiz:
///     輸入: sysclk_p, sysclk_n;
///     輸出: clk_out1 固定 100m Hz;
///           clk_out2 提供給 IDELAYCTRL;
///
//////////////////////////////////////////////////////////////////////////////
module sys_ctrl #(
  /// sys_reset_out 的持續時間(ns);
  parameter RESET_COUNT_NS = 1000,
  /// "ULTRASCALE", "7SERIES", "NONE"
  /// 如果非 "NONE" 則會建立一個 idelayctrl_common_i;
  parameter IDELAYCTRL_SIM_DEVICE = "NONE"
)
(
  input  sysclk_p,
  input  sysclk_n,
  output sysclk_100m_out,

  input  user_reset_in,
  output sys_reset_out
);
//////////////////////////////////////////////////////////////////////////////
wire sysclk_locked;
wire idelayctrl_clk;
// -------------------------------------------
// // 使用 Vivado 2023.1
// // si_0002: 使用單端(sysclk_n沒用到), 若不加上 sysclk_100m_out1 轉介, 則沒有 sysclk_100m_out ??!!
// // 但是這樣反而造成先前的程式在 synth 時: Abnormal program termination (EXCEPTION_ACCESS_VIOLATION) ??!!
// 所以增加一個 sys_ctrl_single.v 使用 [單端] clock 輸入.
//    ==> 後來發現, 只要在 .xdc 增加: create_clock -period 10 [get_ports clk_100M] 即可解決問題;
//  wire   sysclk_100m_out1;
//  assign sysclk_100m_out = sysclk_100m_out1;
//  sysclk_wiz
//  sysclk_wiz_inst(
//    .clk_in1_p (sysclk_p         ),
//    .clk_in1_n (sysclk_n         ),
//    .locked    (sysclk_locked    ),
//    .clk_out1  (sysclk_100m_out1 ),
//    .clk_out2  (idelayctrl_clk   )
//  );
//  ---------------------------------
    sysclk_wiz
    sysclk_wiz_inst(
      .clk_in1_p (sysclk_p         ),
      .clk_in1_n (sysclk_n         ),
      .locked    (sysclk_locked    ),
      .clk_out1  (sysclk_100m_out  ),
      .clk_out2  (idelayctrl_clk   )
    );
// -------------------------------------------
wire sysrst_100m_int;
sync_reset#(.DEPTH(4))
sync_reset_100m_inst (
  .clk     (sysclk_100m_out ),
  .rst_in  (~sysclk_locked  ),
  .rst_out (sysrst_100m_int )
);
// -------------------------------------------
wire syn_user_reset;
sync_reset#(.DEPTH(4))
sync_reset_user_reset_inst(
  .clk     (sysclk_100m_out ),
  .rst_in  (user_reset_in   ),
  .rst_out (syn_user_reset  )
);
//////////////////////////////////////////////////////////////////////////////
localparam                    DELAY_RST_COUNT = RESET_COUNT_NS/10;
localparam                    DELAY_RST_WIDTH = $clog2(DELAY_RST_COUNT + 1);
reg [DELAY_RST_WIDTH-1:0]     delay_rst_cnt = 0;
(* ASYNC_REG = "TRUE" *) reg  delay_rst_d   = 1'b1;
assign                        sys_reset_out = delay_rst_d;
always @(posedge sysclk_100m_out) begin
  delay_rst_cnt <= delay_rst_cnt;
  if (delay_rst_cnt == 0) begin
    delay_rst_d <= 1'b0;
  end else begin
    delay_rst_cnt <= delay_rst_cnt - 1;
  end
  // -----
  if (sysrst_100m_int || syn_user_reset) begin
    delay_rst_cnt <= DELAY_RST_COUNT;
    delay_rst_d   <= 1'b1;
  end
end
//////////////////////////////////////////////////////////////////////////////
if (IDELAYCTRL_SIM_DEVICE != "NONE") begin
  wire   idelayctrl_reset;
  // -----
  sync_reset#(.DEPTH(6))
  idelayctrl_resets_i (
    .clk     (idelayctrl_clk   ),
    .rst_in  (delay_rst_d      ),
    .rst_out (idelayctrl_reset )
  );
  // -----
  IDELAYCTRL #(
     .SIM_DEVICE (IDELAYCTRL_SIM_DEVICE)
  )
  idelayctrl_common_i (
     .REFCLK     (idelayctrl_clk   ),
     .RDY        (idelayctrl_ready ),
     .RST        (idelayctrl_reset )
  );
end
//////////////////////////////////////////////////////////////////////////////
endmodule
