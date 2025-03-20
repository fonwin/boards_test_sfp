`timescale 1ns / 1ps
module test_eth10g #(
  parameter SFP_COUNT = 2
)
(
  input                    sysclk_100m,
  input                    sys_reset,
  input                    sfp_gt_refclk_p,
  input                    sfp_gt_refclk_n,
  output[3:0]              sleds,
  input [SFP_COUNT-1:0]    sfp_rx_p,
  input [SFP_COUNT-1:0]    sfp_rx_n,
  output[SFP_COUNT-1:0]    sfp_tx_p,
  output[SFP_COUNT-1:0]    sfp_tx_n
);
//////////////////////////////////////////////////////////////////////////////
  wire[SFP_COUNT-1:0]   sfp_rx_status;
//////////////////////////////////////////////////////////////////////////////
  assign sleds[0] = ~sfp_rx_status[0];
  assign sleds[1] = 1;
  if (SFP_COUNT > 1) begin
    assign sleds[2] = ~sfp_rx_status[1];
    assign sleds[3] = 1;
  end else begin
    assign sleds[2] = 1;
    assign sleds[3] = 1;
  end
//////////////////////////////////////////////////////////////////////////////
  wire [  7 : 0]  pcspma_status       [SFP_COUNT];
  wire [  2 : 0]  mac_status_vector   [SFP_COUNT];
  wire [ 29 : 0]  rx_statistics_vector[SFP_COUNT];
  wire            rx_statistics_valid [SFP_COUNT];
  wire            axis_tx_clk         [SFP_COUNT];
  wire            axis_tx_tvalid      [SFP_COUNT];
  wire            axis_tx_tready      [SFP_COUNT];
  wire [63 : 0]   axis_tx_tdata       [SFP_COUNT];
  wire [7  : 0]   axis_tx_tkeep       [SFP_COUNT];
  wire            axis_tx_tlast       [SFP_COUNT];
  wire [0 : 0]    axis_tx_tuser       [SFP_COUNT];
  assign axis_tx_tuser[0] = 0;
  if (SFP_COUNT > 1) begin
    assign axis_tx_tuser[1] = 0;
  end

  wire            axis_rx_clk         [SFP_COUNT];
  wire            axis_rx_tvalid      [SFP_COUNT];
  wire            axis_rx_tready      [SFP_COUNT];
  wire [63 : 0]   axis_rx_tdata       [SFP_COUNT];
  wire [7  : 0]   axis_rx_tkeep       [SFP_COUNT];
  wire            axis_rx_tlast       [SFP_COUNT];
  wire [0 : 0]    axis_rx_tuser       [SFP_COUNT];
//////////////////////////////////////////////////////////////////////////////
  wire qplllock;
  wire qplloutclk;
  wire qplloutrefclk;
  wire coreclk;
  wire reset_counter_done;
  wire gttxreset;
  wire gtrxreset;
  wire txusrclk;
  wire txusrclk2;
  wire txuserrdy;
// --------------------------------------------------- //
  eth10g
  eth10g_i (
    .dclk                     (sysclk_100m         ),
    .tx_axis_aresetn          (~sys_reset          ),
    .rx_axis_aresetn          (~sys_reset          ),
    .reset                    (sys_reset           ),
    .coreclk_out              (coreclk             ),
    .resetdone_out            (),
    .reset_counter_done_out   (reset_counter_done  ),
    .signal_detect            (1'b1                ),
    .sim_speedup_control      (1'b1                ),
    .xgmacint                 (),
    .areset_datapathclk_out   (),

    .pcspma_status            (pcspma_status[0]    ),
    .txp                      (sfp_tx_p     [0]    ),
    .txn                      (sfp_tx_n     [0]    ),
    .rxp                      (sfp_rx_p     [0]    ),
    .rxn                      (sfp_rx_n     [0]    ),
    .refclk_p                 (sfp_gt_refclk_p     ),
    .refclk_n                 (sfp_gt_refclk_n     ),

    .qplllock_out             (qplllock            ),
    .qplloutclk_out           (qplloutclk          ),
    .qplloutrefclk_out        (qplloutrefclk       ),
    .gttxreset_out            (gttxreset           ),
    .gtrxreset_out            (gtrxreset           ),

    .s_axi_aclk               (sysclk_100m   ),
    .s_axi_aresetn            (~sys_reset    ),
    .s_axi_arvalid            (0             ),
    .s_axi_araddr             (0             ),
    .s_axi_arready            (              ),
    .s_axi_awvalid            (0             ),
    .s_axi_awaddr             (0             ),
    .s_axi_awready            (              ),
    .s_axi_bvalid             (              ),
    .s_axi_bready             (0             ),
    .s_axi_rvalid             (              ),
    .s_axi_rready             (0             ),
    .s_axi_bresp              (              ),
    .s_axi_rdata              (              ),
    .s_axi_rresp              (              ),
    .s_axi_wvalid             (0             ),
    .s_axi_wdata              (0             ),
    .s_axi_wready             (              ),

    .tx_ifg_delay             (0             ),
    .tx_fault                 (1'b0          ),
    .tx_disable               (              ),

    .txusrclk2_out            (txusrclk2              ),
    .txuserrdy_out            (txuserrdy              ),
    .txusrclk_out             (txusrclk               ),
    .s_axis_tx_tvalid         (axis_tx_tvalid[0]      ),
    .s_axis_tx_tready         (axis_tx_tready[0]      ),
    .s_axis_tx_tlast          (axis_tx_tlast [0]      ),
    .s_axis_tx_tkeep          (axis_tx_tkeep [0]      ),
    .s_axis_tx_tdata          (axis_tx_tdata [0]      ),
    .s_axis_tx_tuser          (axis_tx_tuser [0]      ),
    .s_axis_pause_tdata       (0                      ),
    .s_axis_pause_tvalid      (0                      ),
    .tx_statistics_valid      (                       ),
    .tx_statistics_vector     (                       ),

    .rxrecclk_out             (                       ),
    .m_axis_rx_tvalid         (axis_rx_tvalid      [0]),
    .m_axis_rx_tlast          (axis_rx_tlast       [0]),
    .m_axis_rx_tkeep          (axis_rx_tkeep       [0]),
    .m_axis_rx_tdata          (axis_rx_tdata       [0]),
    .m_axis_rx_tuser          (axis_rx_tuser       [0]),
    .rx_statistics_valid      (rx_statistics_valid [0]),
    .rx_statistics_vector     (rx_statistics_vector[0])
  );
  assign axis_tx_clk[0] = coreclk;
  assign axis_rx_clk[0] = coreclk;
//////////////////////////////////////////////////////////////////////////////
if (SFP_COUNT > 1) begin
  eth10s
  eth10s_i (
    .dclk                     (sysclk_100m         ),
    .tx_axis_aresetn          (~sys_reset          ),
    .rx_axis_aresetn          (~sys_reset          ),
    .areset                   (sys_reset           ),
    .coreclk                  (coreclk             ),
    .areset_coreclk           (sys_reset           ),
    .reset_counter_done       (reset_counter_done  ),
    .signal_detect            (1'b1                ),
    .sim_speedup_control      (1'b1                ),
    .xgmacint                 (),

    .pcspma_status            (pcspma_status[1]    ),
    .txp                      (sfp_tx_p     [1]    ),
    .txn                      (sfp_tx_n     [1]    ),
    .rxp                      (sfp_rx_p     [1]    ),
    .rxn                      (sfp_rx_n     [1]    ),

    .qplllock                 (qplllock            ),
    .qplloutclk               (qplloutclk          ),
    .qplloutrefclk            (qplloutrefclk       ),
    .gttxreset                (gttxreset           ),
    .gtrxreset                (gtrxreset           ),

    .s_axi_aclk               (sysclk_100m   ),
    .s_axi_aresetn            (~sys_reset    ),
    .s_axi_arvalid            (0             ),
    .s_axi_araddr             (0             ),
    .s_axi_arready            (              ),
    .s_axi_awvalid            (0             ),
    .s_axi_awaddr             (0             ),
    .s_axi_awready            (              ),
    .s_axi_bvalid             (              ),
    .s_axi_bready             (0             ),
    .s_axi_rvalid             (              ),
    .s_axi_rready             (0             ),
    .s_axi_bresp              (              ),
    .s_axi_rdata              (              ),
    .s_axi_rresp              (              ),
    .s_axi_wvalid             (0             ),
    .s_axi_wdata              (0             ),
    .s_axi_wready             (              ),

    .tx_ifg_delay             (0             ),
    .tx_fault                 (1'b0          ),
    .tx_disable               (              ),

    .txusrclk2                (txusrclk2              ),
    .txuserrdy                (txuserrdy              ),
    .txusrclk                 (txusrclk               ),
    .s_axis_tx_tvalid         (axis_tx_tvalid[1]      ),
    .s_axis_tx_tready         (axis_tx_tready[1]      ),
    .s_axis_tx_tlast          (axis_tx_tlast [1]      ),
    .s_axis_tx_tkeep          (axis_tx_tkeep [1]      ),
    .s_axis_tx_tdata          (axis_tx_tdata [1]      ),
    .s_axis_tx_tuser          (axis_tx_tuser [1]      ),
    .s_axis_pause_tdata       (0                      ),
    .s_axis_pause_tvalid      (0                      ),
    .tx_statistics_valid      (                       ),
    .tx_statistics_vector     (                       ),

    .rxrecclk_out             (                       ),
    .m_axis_rx_tvalid         (axis_rx_tvalid      [1]),
    .m_axis_rx_tlast          (axis_rx_tlast       [1]),
    .m_axis_rx_tkeep          (axis_rx_tkeep       [1]),
    .m_axis_rx_tdata          (axis_rx_tdata       [1]),
    .m_axis_rx_tuser          (axis_rx_tuser       [1]),
    .rx_statistics_valid      (rx_statistics_valid [1]),
    .rx_statistics_vector     (rx_statistics_vector[1])
  );
  assign axis_tx_clk[1] = coreclk;
  assign axis_rx_clk[1] = coreclk;
end
//////////////////////////////////////////////////////////////////////////////
  wire            axis_tx_0_clk    = axis_tx_clk   [SFP_COUNT-1];
  wire            axis_tx_0_tvalid = axis_tx_tvalid[SFP_COUNT-1];
  wire            axis_tx_0_tready = axis_tx_tready[SFP_COUNT-1];
  wire [63 : 0]   axis_tx_0_tdata  = axis_tx_tdata [SFP_COUNT-1];
  wire [7  : 0]   axis_tx_0_tkeep  = axis_tx_tkeep [SFP_COUNT-1];
  wire            axis_tx_0_tlast  = axis_tx_tlast [SFP_COUNT-1];
  wire [0 : 0]    axis_tx_0_tuser  = axis_tx_tuser [SFP_COUNT-1];

  localparam IN_FIFO_DATA_WIDTH = 64 + 8 + 1;
  xpm_fifo_async # (
    .FIFO_MEMORY_TYPE          ("block"   ), // "auto", "block", or "distributed";
    .ECC_MODE                  ("no_ecc"  ), // "no_ecc" or "en_ecc";
    .RELATED_CLOCKS            (0         ), // 0 or 1
    .FIFO_WRITE_DEPTH          (16        ), // 因為預期 wr_clk(8 ns) 比 rd_clk(6.4 ns) 慢, 所以緩衝不必太大, 主要是為了 CDC;
    .WRITE_DATA_WIDTH          (IN_FIFO_DATA_WIDTH),
    .WR_DATA_COUNT_WIDTH       (12        ),
    .PROG_FULL_THRESH          (10        ),
    .FULL_RESET_VALUE          (0         ), // 0 or 1
    .USE_ADV_FEATURES          ("1000"    ), // string; "0000" to "1F1F"; [12]:data_valid
    .READ_MODE                 ("fwft"    ), // "std" or "fwft" or "low_latency_fwft"(可少一個 wr_clk cycle, 但 mem type 只能是 lutram/distributed);
    .FIFO_READ_LATENCY         (0         ), // 1 for "std"; 0 for "fwft";
    .READ_DATA_WIDTH           (IN_FIFO_DATA_WIDTH),
    .RD_DATA_COUNT_WIDTH       (12        ),
    .PROG_EMPTY_THRESH         (10        ),
    .DOUT_RESET_VALUE          ("0"       ),
    .CDC_SYNC_STAGES           (2         ),
    .WAKEUP_TIME               (0         )
  ) loopback_fifo_1 (
    .rst              (sys_reset          ),

    .wr_rst_busy      (                   ),
    .wr_clk           (axis_rx_clk[0]     ),
    .wr_en            (axis_rx_tvalid[0]  ),
    .din              ({axis_rx_tlast[0], axis_rx_tkeep[0], axis_rx_tdata[0]}),
    .wr_data_count    (),
    .wr_ack           (),
    .overflow         (),
    .full             (),
    .prog_full        (),
    .almost_full      (),

    .rd_rst_busy      (                 ),
    .rd_clk           (axis_tx_0_clk    ),
    .rd_en            (axis_tx_0_tready ),
    .dout             ({axis_tx_0_tlast, axis_tx_0_tkeep, axis_tx_0_tdata}),
    .data_valid       (axis_tx_0_tvalid ),
    .rd_data_count    (),
    .underflow        (),
    .empty            (),
    .prog_empty       (),
    .almost_empty     (),

    .sleep            (1'b0            ),
    .injectsbiterr    (1'b0            ),
    .injectdbiterr    (1'b0            ),
    .sbiterr          (),
    .dbiterr          ()
  );

if (SFP_COUNT > 1) begin
  xpm_fifo_async # (
    .FIFO_MEMORY_TYPE          ("block"   ), // "auto", "block", or "distributed";
    .ECC_MODE                  ("no_ecc"  ), // "no_ecc" or "en_ecc";
    .RELATED_CLOCKS            (0         ), // 0 or 1
    .FIFO_WRITE_DEPTH          (16        ), // 因為預期 wr_clk(8 ns) 比 rd_clk(6.4 ns) 慢, 所以緩衝不必太大, 主要是為了 CDC;
    .WRITE_DATA_WIDTH          (IN_FIFO_DATA_WIDTH),
    .WR_DATA_COUNT_WIDTH       (12        ),
    .PROG_FULL_THRESH          (10        ),
    .FULL_RESET_VALUE          (0         ), // 0 or 1
    .USE_ADV_FEATURES          ("1000"    ), // string; "0000" to "1F1F"; [12]:data_valid
    .READ_MODE                 ("fwft"    ), // "std" or "fwft" or "low_latency_fwft"(可少一個 wr_clk cycle, 但 mem type 只能是 lutram/distributed);
    .FIFO_READ_LATENCY         (0         ), // 1 for "std"; 0 for "fwft";
    .READ_DATA_WIDTH           (IN_FIFO_DATA_WIDTH),
    .RD_DATA_COUNT_WIDTH       (12        ),
    .PROG_EMPTY_THRESH         (10        ),
    .DOUT_RESET_VALUE          ("0"       ),
    .CDC_SYNC_STAGES           (2         ),
    .WAKEUP_TIME               (0         )
  ) loopback_fifo_2 (
    .rst              (sys_reset          ),

    .wr_rst_busy      (                   ),
    .wr_clk           (axis_rx_clk[1]     ),
    .wr_en            (axis_rx_tvalid[1]  ),
    .din              ({axis_rx_tlast[1], axis_rx_tkeep[1], axis_rx_tdata[1]}),
    .wr_data_count    (),
    .wr_ack           (),
    .overflow         (),
    .full             (),
    .prog_full        (),
    .almost_full      (),

    .rd_rst_busy      (                  ),
    .rd_clk           (axis_tx_clk[0]    ),
    .rd_en            (axis_tx_tready[0] ),
    .dout             ({axis_tx_tlast[0], axis_tx_tkeep[0], axis_tx_tdata[0]}),
    .data_valid       (axis_tx_tvalid[0] ),
    .rd_data_count    (),
    .underflow        (),
    .empty            (),
    .prog_empty       (),
    .almost_empty     (),

    .sleep            (1'b0            ),
    .injectsbiterr    (1'b0            ),
    .injectdbiterr    (1'b0            ),
    .sbiterr          (),
    .dbiterr          ()
  );
end
//////////////////////////////////////////////////////////////////////////////
  localparam VIO_WIDTH  = 128;
  wire   vio_clk = coreclk;
//////////////////////////////////////////////////////////////////////////////
  wire[VIO_WIDTH-1:0] rx_ready_cnt[2];
  wire[VIO_WIDTH-1:0] rx_frame_cnt[2];

genvar gL;
generate for(gL = 0; gL < SFP_COUNT; gL = gL + 1) begin
  assign sfp_rx_status[gL] = pcspma_status[gL][0];
  signal_counter #( .COUNTER_WIDTH(VIO_WIDTH) ) rx_ready_cnt_0( .clk(vio_clk),         .rst(sys_reset), .signal_in(sfp_rx_status[gL]), .counter_out(rx_ready_cnt[gL]) );
  signal_counter #( .COUNTER_WIDTH(VIO_WIDTH) ) rx_frame_cnt_0( .clk(axis_rx_clk[gL]), .rst(sys_reset), .signal_in(axis_rx_tlast[gL]), .counter_out(rx_frame_cnt[gL]) );
end endgenerate

//////////////////////////////////////////////////////////////////////////////
if (SFP_COUNT == 1) begin
  vio_2
  vio_2_i(
    .probe_in0  (rx_ready_cnt[0] ),
    .probe_in1  (rx_frame_cnt[0] ),
    .clk        (vio_clk         )
  );
end else begin
  vio_4
  vio_4_i(
    .probe_in0  (rx_ready_cnt[0] ),
    .probe_in1  (rx_frame_cnt[0] ),
    .probe_in2  (rx_ready_cnt[1] ),
    .probe_in3  (rx_frame_cnt[1] ),
    .clk        (vio_clk         )
  );
end
//////////////////////////////////////////////////////////////////////////////
endmodule
//////////////////////////////////////////////////////////////////////////////
