`timescale 1ns / 1ps
module test_pcspma #(
  parameter SFP_COUNT = 2
)
(
  input                    sysclk_100m,
  input                    sys_reset,
  output                   user_reset_out,
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
  wire[63:0]   xgmii_txd    [SFP_COUNT];
  wire[ 7:0]   xgmii_txc    [SFP_COUNT];
  wire[63:0]   xgmii_rxd    [SFP_COUNT];
  wire[ 7:0]   xgmii_rxc    [SFP_COUNT];
  wire[ 7:0]   core_status  [SFP_COUNT];

  wire[447:0]  status_vector[2];
  // 256      10GBASE-R PCS RX Locked
  // 257      10GBASE-R PCS high BER
  // 268      10GBASE-R PCS RX Link Status
  // 285:280  10GBASE-R PCS BER Counter
  wire         rx_hiber_st[2];
  assign rx_hiber_st[0] = status_vector[0][257];
  assign rx_hiber_st[1] = status_vector[1][257];

  // 10GBASE-R only: Set this to a constant to define the PMA/PMD
  // type as described in IEEE 802.3 section 45.2.1.6:
  // 111 = 10GBASE-SR
  // 110 = 10GBASE-LR
  // 101 = 10GBASE-ER
  wire[ 2:0]   pma_pmd_type = 3'b101;
  wire[535:0]  configuration_vector = 0;
//////////////////////////////////////////////////////////////////////////////
  wire qplloutclk;
  wire qplloutrefclk;
  wire qplllock;
  wire coreclk;

  wire reset_counter_done;
  wire gttxreset;
  wire gtrxreset;
  wire txusrclk;
  wire txusrclk2;
  wire txuserrdy;
// --------------------------------------------------- //
  pcspma_m
  pcspma_m_i(
    .dclk                     (sysclk_100m         ),
    .reset                    (sys_reset           ),
    .refclk_p                 (sfp_gt_refclk_p     ),
    .refclk_n                 (sfp_gt_refclk_n     ),
    .qplloutclk_out           (qplloutclk          ),
    .qplloutrefclk_out        (qplloutrefclk       ),
    .qplllock_out             (qplllock            ),
    .coreclk_out              (coreclk             ),
    .gttxreset_out            (gttxreset           ),
    .gtrxreset_out            (gtrxreset           ),
    .reset_counter_done_out   (reset_counter_done  ),
    .areset_datapathclk_out   (                    ),
    .sim_speedup_control      (1'b1                ),
//  .gt0_eyescanreset         (0),
//  .gt0_eyescantrigger       (0),
//  .gt0_txprbsforceerr       (0),
//  .gt0_rxcdrhold            (0),//RX Clock Data Recovery Hold (RX CDR Hold): 0=正常; 1=CDR鎖定當前時鐘，不再調整;
//  .gt0_txpolarity           (0),//設定 TX 差分對 (TXP/TXN) 的極性: 0=正常, 1=對調;
//  .gt0_rxpolarity           (0),//設定 RX 差分對 (RXP/RXN) 的極性: 0=正常, 1=對調;
//  .gt0_rxrate               (0),//[2:0] 0=全速運行(No division)x1:10.3125Gbps; 1=1/2速率(÷2); 2=1/4速率(÷4); 3=1/8速率(÷8)
//  .gt0_txpmareset           (sys_reset),//tx pma reset;
//  .gt0_rxpmareset           (sys_reset),//rx pma reset;
//  .gt0_rxdfelpmreset        (sys_reset),//rx dfe lpm reset
//  .gt0_rxlpmen              (0),// RX Low Power Mode Enable (RX LPM Enable): 1=LPM; 0=CTLE+DFE;
//  .gt0_txprecursor          (5'b00111),// 1.67 dB
//  .gt0_txpostcursor         (5'b00011),// 0.68 dB
//  .gt0_txdiffctrl           (4'b1100 ),// 1018 mV
//  .gt0_eyescandataerror     (),//output         
//  .gt0_txbufstatus          (),//output  [1 : 0]
//  .gt0_txresetdone          (),//output         
//  .gt0_rxresetdone          (),//output         
//  .gt0_rxbufstatus          (),//output  [2 : 0]
//  .gt0_rxprbserr            (),//output         
//  .gt0_dmonitorout          (),//output  [7 : 0]

    .txusrclk_out             (txusrclk            ),
    .txusrclk2_out            (txusrclk2           ),
    .txuserrdy_out            (txuserrdy           ),  

    .configuration_vector     (configuration_vector),
    .status_vector            (status_vector[0]    ),
    .core_status              (core_status  [0]    ),
    .txp                      (sfp_tx_p     [0]    ),
    .txn                      (sfp_tx_n     [0]    ),
    .xgmii_txd                (xgmii_txd    [0]    ),
    .xgmii_txc                (xgmii_txc    [0]    ),
    .rxp                      (sfp_rx_p     [0]    ),
    .rxn                      (sfp_rx_n     [0]    ),
    .xgmii_rxd                (xgmii_rxd    [0]    ),
    .xgmii_rxc                (xgmii_rxc    [0]    ),
    .rxrecclk_out             (                    ),
    .resetdone_out            (                    ),

    .signal_detect            (1             ),//input           
    .tx_fault                 (0             ),//input           
    .tx_disable               (              ),//output          
    .pma_pmd_type             (pma_pmd_type  ),//input [2:0]     

    .drp_req      ( ),//output          
    .drp_gnt      (0),//input           
    .drp_den_o    ( ),//output          
    .drp_dwe_o    ( ),//output          
    .drp_daddr_o  ( ),//output [15 : 0] 
    .drp_di_o     ( ),//output [15 : 0] 
    .drp_drdy_o   ( ),//output          
    .drp_drpdo_o  ( ),//output [15 : 0] 
    .drp_den_i    (0),//input           
    .drp_dwe_i    (0),//input           
    .drp_daddr_i  (0),//input  [15 : 0] 
    .drp_di_i     (0),//input  [15 : 0] 
    .drp_drdy_i   (0),//input           
    .drp_drpdo_i  (0) //input  [15 : 0] 
  );
//////////////////////////////////////////////////////////////////////////////
if (SFP_COUNT > 1) begin
  pcspma_s
  pcspma_s_i (
    .dclk                     (sysclk_100m         ),
    .areset                   (sys_reset           ),
    .areset_coreclk           (sys_reset           ),   
    .qplloutclk               (qplloutclk          ),
    .qplloutrefclk            (qplloutrefclk       ),
    .qplllock                 (qplllock            ),
    .coreclk                  (coreclk             ),
    .gttxreset                (gttxreset           ),
    .gtrxreset                (gtrxreset           ),
    .reset_counter_done       (reset_counter_done  ),
    .sim_speedup_control      (1'b1                ),
//  .gt0_eyescanreset         (0),
//  .gt0_eyescantrigger       (0),
//  .gt0_txprbsforceerr       (0),
//  .gt0_rxcdrhold            (0),//RX Clock Data Recovery Hold (RX CDR Hold): 0=正常; 1=CDR鎖定當前時鐘，不再調整;
//  .gt0_txpolarity           (0),//設定 TX 差分對 (TXP/TXN) 的極性: 0=正常, 1=對調;
//  .gt0_rxpolarity           (0),//設定 RX 差分對 (RXP/RXN) 的極性: 0=正常, 1=對調;
//  .gt0_rxrate               (0),//[2:0] 0=全速運行(No division)x1:10.3125Gbps; 1=1/2速率(÷2); 2=1/4速率(÷4); 3=1/8速率(÷8)
//  .gt0_txpmareset           (sys_reset),//tx pma reset;
//  .gt0_rxpmareset           (sys_reset),//rx pma reset;
//  .gt0_rxdfelpmreset        (sys_reset),//rx dfe lpm reset
//  .gt0_rxlpmen              (0),// RX Low Power Mode Enable (RX LPM Enable): 1=LPM; 0=CTLE+DFE;
//  .gt0_txprecursor          (5'b00111),// 1.67 dB
//  .gt0_txpostcursor         (5'b00011),// 0.68 dB
//  .gt0_txdiffctrl           (4'b1100 ),// 1018 mV
//  .gt0_eyescandataerror     (),//output         
//  .gt0_txbufstatus          (),//output  [1 : 0]
//  .gt0_txresetdone          (),//output         
//  .gt0_rxresetdone          (),//output         
//  .gt0_rxbufstatus          (),//output  [2 : 0]
//  .gt0_rxprbserr            (),//output         
//  .gt0_dmonitorout          (),//output  [7 : 0]

    .txusrclk                 (txusrclk            ),
    .txusrclk2                (txusrclk2           ),  
    .txuserrdy                (txuserrdy           ),  
    .tx_resetdone             (                    ),
    .txoutclk                 (                    ),

    .configuration_vector     (configuration_vector),
    .status_vector            (status_vector[1]    ),
    .core_status              (core_status  [1]    ),
    .txp                      (sfp_tx_p     [1]    ),
    .txn                      (sfp_tx_n     [1]    ),
    .xgmii_txd                (xgmii_txd    [1]    ),
    .xgmii_txc                (xgmii_txc    [1]    ),
    .rxp                      (sfp_rx_p     [1]    ),
    .rxn                      (sfp_rx_n     [1]    ),
    .xgmii_rxd                (xgmii_rxd    [1]    ),
    .xgmii_rxc                (xgmii_rxc    [1]    ),
    .rxrecclk_out             (                    ),
    .rx_resetdone             (                    ),

    .signal_detect            (1             ),//input           
    .tx_fault                 (0             ),//input           
    .tx_disable               (              ),//output          
    .pma_pmd_type             (pma_pmd_type  ),//input [2:0]     

    .drp_req      ( ),//output          
    .drp_gnt      (0),//input           
    .drp_den_o    ( ),//output          
    .drp_dwe_o    ( ),//output          
    .drp_daddr_o  ( ),//output [15 : 0] 
    .drp_di_o     ( ),//output [15 : 0] 
    .drp_drdy_o   ( ),//output          
    .drp_drpdo_o  ( ),//output [15 : 0] 
    .drp_den_i    (0),//input           
    .drp_dwe_i    (0),//input           
    .drp_daddr_i  (0),//input  [15 : 0] 
    .drp_di_i     (0),//input  [15 : 0] 
    .drp_drdy_i   (0),//input           
    .drp_drpdo_i  (0) //input  [15 : 0] 
  );
end
//////////////////////////////////////////////////////////////////////////////
localparam[63:0]  XGMII_IDLE_D = 64'h07_07_07_07_07_07_07_07;
localparam[ 7:0]  XGMII_IDLE_C = 8'hff;

if (SFP_COUNT == 1) begin
    assign xgmii_txd[0] = XGMII_IDLE_D;// xgmii_rxd[0];
    assign xgmii_txc[0] = XGMII_IDLE_C;// xgmii_rxc[0];
end else if (SFP_COUNT > 1) begin
    assign xgmii_txd[0] = XGMII_IDLE_D;// xgmii_rxd[1];
    assign xgmii_txc[0] = XGMII_IDLE_C;// xgmii_rxc[1];
    assign xgmii_txd[1] = XGMII_IDLE_D;// xgmii_rxd[0];
    assign xgmii_txc[1] = XGMII_IDLE_C;// xgmii_rxc[0];
end
//////////////////////////////////////////////////////////////////////////////
  localparam VIO_WIDTH  = 128;
  wire   vio_clk = coreclk;
//////////////////////////////////////////////////////////////////////////////
  wire[VIO_WIDTH-1:0] rx_ready_cnt[2];
  reg [VIO_WIDTH-1:0] rx_nidle_cnt[2];
  reg [VIO_WIDTH-1:0] rx_xgmii[2];
  wire                clear_cnt;

genvar gL;
generate for(gL = 0; gL < SFP_COUNT; gL = gL + 1) begin
  assign sfp_rx_status[gL] = core_status[gL][0];
  signal_counter #( .COUNTER_WIDTH(VIO_WIDTH) ) rx_ready_cnt_i ( .clk(vio_clk), .rst(sys_reset|clear_cnt), .signal_in(sfp_rx_status[gL]), .counter_out(rx_ready_cnt[gL]) );
  always @(posedge vio_clk) begin
    if ({ xgmii_rxc[gL], xgmii_rxd[gL] } != {XGMII_IDLE_C, XGMII_IDLE_D}) begin
      rx_xgmii[gL]     <= { xgmii_rxc[gL], xgmii_rxd[gL] };
      rx_nidle_cnt[gL] <= rx_nidle_cnt[gL] + 1;
    end
    if (~sfp_rx_status[gL] || sys_reset || clear_cnt) begin
      rx_nidle_cnt[gL] <= 0;
    end
  end
end endgenerate
//////////////////////////////////////////////////////////////////////////////
if (SFP_COUNT == 1) begin
  vio_3
  vio_3_i(
    .probe_in0  (rx_ready_cnt[0] ),
    .probe_in1  (rx_nidle_cnt[0] ),
    .probe_in2  (rx_xgmii    [0] ),
    .probe_out0 (user_reset_out  ),
    .probe_out1 (clear_cnt       ),
    .clk        (vio_clk         )
  );
end else begin
  vio_6
  vio_6_i(
    .probe_in0  (rx_ready_cnt[0] ),
    .probe_in1  (rx_nidle_cnt[0] ),
    .probe_in2  (rx_xgmii    [0] ),
    .probe_in3  (rx_ready_cnt[1] ),
    .probe_in4  (rx_nidle_cnt[1] ),
    .probe_in5  (rx_xgmii    [1] ),
    .probe_out0 (user_reset_out  ),
    .probe_out1 (clear_cnt       ),
    .clk        (vio_clk         )
  );
end
//////////////////////////////////////////////////////////////////////////////
endmodule
//////////////////////////////////////////////////////////////////////////////
