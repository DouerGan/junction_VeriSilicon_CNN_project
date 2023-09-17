`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2023/09/16 11:00:51
// Design Name:
// Module Name: SlidingWindow_150
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module SlidingWindow_150 #(
    parameter               P_CNT_COL_MAX = 150,
    parameter               P_CNT_ROW_MAX = 150

)(
    input                       jct_i_clk         ,
    input                       jct_i_rst         , //时钟与复位信号

    input       [7:0]           jct_i_d_dataflow  ,
    input                       jct_i_c_valid     ,

    output      [7:0]           jct_o_d_data0     ,
    output      [7:0]           jct_o_d_data1     ,
    output      [7:0]           jct_o_d_data2     ,
    output                      jct_o_c_valid
    );
/***************例化IP核**************/
fifo_generator_0 FIFO_SlidingWindow1 (
  .clk                          (jct_i_clk        ),// 同步FIFO时钟
  .rst                          (jct_i_rst        ),// 复位
  .din                          (jct_r_wr_data_1  ),// 写数据
  .wr_en                        (jct_r_wr_en_1    ),// 写使能
  .rd_en                        (jct_r_rd_en      ),// 读使能
  .dout                         (jct_w_dataout_1  ),// 读数据
  .full                         (                 ),
  .empty                        (                 ),
  .wr_rst_busy                  (                 ),
  .rd_rst_busy                  (                 )
);
fifo_generator_0 FIFO_SlidingWindow2 (
  .clk                          (jct_i_clk        ),// 同步FIFO时钟
  .rst                          (jct_i_rst        ),// 复位
  .din                          (jct_r_wr_data_2  ),// 写数据
  .wr_en                        (jct_r_wr_en_2    ),// 写使能
  .rd_en                        (jct_r_rd_en      ),// 读使能
  .dout                         (jct_w_dataout_2  ),// 读数据
  .full                         (                 ),
  .empty                        (                 ),
  .wr_rst_busy                  (                 ),
  .rd_rst_busy                  (                 )
);
/***************reg*******************/
reg             [7:0]           jct_r_cnt_col      ;
reg             [7:0]           jct_r_cnt_row      ;
reg                             jct_r_wr_en_1      ;
reg             [7:0]           jct_r_wr_data_1    ;
reg                             jct_r_wr_en_2      ;
reg             [7:0]           jct_r_wr_data_2    ;
reg                             jct_r_rd_en        ;
reg                             jct_ro_c_valid     ;
reg                             jct_ro_all_OK      ;
/***************wire******************/
wire            [7:0]           jct_w_dataout_1    ;
wire            [7:0]           jct_w_dataout_2    ;
/***************assign****************/
assign jct_o_d_data1 = jct_w_dataout_1;
assign jct_o_d_data2 = jct_w_dataout_2;
assign jct_o_d_data0 = jct_i_d_dataflow;
assign jct_o_c_valid = jct_ro_all_OK  ;
/***************always****************/
always @(posedge jct_i_clk or posedge jct_i_rst)//列计数器
begin
    if(jct_i_rst)
        jct_r_cnt_col <= 0;
    else if(jct_r_cnt_col == P_CNT_COL_MAX - 1 && jct_i_c_valid)
        jct_r_cnt_col <= 0;
    else if(jct_i_c_valid)
        jct_r_cnt_col <= jct_r_cnt_col + 1;
    else
        jct_r_cnt_col <= jct_r_cnt_col;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//行计数器
begin
    if(jct_i_rst)
        jct_r_cnt_row <= 0;
    else if(jct_r_cnt_row == P_CNT_ROW_MAX -1 && jct_r_cnt_col == P_CNT_COL_MAX - 1 && jct_i_c_valid)
        jct_r_cnt_row <= 0;
    else if(jct_r_cnt_col == P_CNT_COL_MAX - 1 && jct_i_c_valid)
        jct_r_cnt_row <= jct_r_cnt_row +1;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//FIFO1的写使能信号
begin
    if(jct_i_rst)
      jct_r_wr_en_1 <= 0;
    else if(jct_r_cnt_row == 0 && jct_i_c_valid )
      jct_r_wr_en_1 <= 1;
    else
      jct_r_wr_en_1 <= jct_ro_c_valid;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//FIFO1的写数据
begin
    if(jct_i_rst)
      jct_r_wr_data_1 <= 0;
    else if(jct_r_cnt_row == 0 && jct_i_c_valid)
      jct_r_wr_data_1 <= jct_i_d_dataflow;
    else if(jct_ro_c_valid)
      jct_r_wr_data_1 <= jct_w_dataout_2;
    else
      jct_r_wr_data_1 <= jct_r_wr_data_1;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//FIFO2的写使能信号
begin
    if(jct_i_rst)
      jct_r_wr_en_2 <= 0;
    else if(jct_r_cnt_row >= 1 && (jct_r_cnt_row <= P_CNT_ROW_MAX -2) && jct_i_c_valid )
      jct_r_wr_en_2 <= 1;
    else
      jct_r_wr_en_2 <= 0;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//FIFO2的写数据
begin
    if(jct_i_rst)
      jct_r_wr_data_2 <= 0;
    else if(jct_r_cnt_row >= 1 && (jct_r_cnt_row <= P_CNT_ROW_MAX -2) && jct_i_c_valid )
      jct_r_wr_data_2 <= jct_i_d_dataflow;
    else
      jct_r_wr_data_2 <= jct_r_wr_data_2;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//FIFO的读使能信号
begin
    if(jct_i_rst)
      jct_r_rd_en <= 0;
    else if(jct_r_cnt_row >= 2 && (jct_r_cnt_row <= P_CNT_ROW_MAX -1) && jct_i_c_valid )
      jct_r_rd_en <= 1;
    else
      jct_r_rd_en <= 0;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//valid信号输出
begin
    if(jct_i_rst)
      jct_ro_c_valid <= 0;
    else if( jct_r_wr_en_2 && jct_r_rd_en)
      jct_ro_c_valid <= 1;
    else
      jct_ro_c_valid <= 0;
end

always @(posedge jct_i_clk or posedge jct_i_rst)//valid信号输出
begin
    if(jct_i_rst)
      jct_ro_all_OK <= 0;
    else if(jct_r_rd_en)
      jct_ro_all_OK <= 1;
    else
      jct_ro_all_OK <= 0;
end
endmodule
