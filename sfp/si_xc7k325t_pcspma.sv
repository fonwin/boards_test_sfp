`timescale 1ns / 1ps
module si_xc7k325t_pcspma #(
  parameter SFP_COUNT = 2
)
(
  input                    clk_200M_p,
  input                    clk_200M_n,
  input                    sfp_gt_refclk_p,
  input                    sfp_gt_refclk_n,
  output[3:0]              sleds,
  input [SFP_COUNT-1:0]    sfp_rx_p,
  input [SFP_COUNT-1:0]    sfp_rx_n,
  output[SFP_COUNT-1:0]    sfp_tx_p,
  output[SFP_COUNT-1:0]    sfp_tx_n
);
//////////////////////////////////////////////////////////////////////////////
  wire sysclk_100m;
  wire sys_reset;
  sys_ctrl#(
    .IDELAYCTRL_SIM_DEVICE ("NONE")
  )
  sys_ctrl_inst(
    .sysclk_p        (clk_200M_p      ),
    .sysclk_n        (clk_200M_n      ),
    .sysclk_100m_out (sysclk_100m     ),
    .user_reset_in   (1'b0            ),
    .sys_reset_out   (sys_reset       )
  );
//////////////////////////////////////////////////////////////////////////////
  test_pcspma #(
    .SFP_COUNT       (SFP_COUNT       )
  )
  test_pcspma_i(
    .sysclk_100m     (sysclk_100m     ),
    .sys_reset       (sys_reset       ),
    .sleds           (sleds           ),
    .sfp_gt_refclk_p (sfp_gt_refclk_p ),
    .sfp_gt_refclk_n (sfp_gt_refclk_n ),
    .sfp_rx_p        (sfp_rx_p        ),
    .sfp_rx_n        (sfp_rx_n        ),
    .sfp_tx_p        (sfp_tx_p        ),
    .sfp_tx_n        (sfp_tx_n        )
  );
//////////////////////////////////////////////////////////////////////////////
endmodule
//////////////////////////////////////////////////////////////////////////////
