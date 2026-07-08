`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 23:13:51
// Design Name: 
// Module Name: framepacketreceiver
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
module framepacketreceiver(
input stream,
input clk,
input reset ,
output reg done,
output reg parity_err,
output reg  frame_err,
output reg [7:0] data_out
    );
reg [7:0] shift_reg;
reg [3:0] count ;
localparam IDLE=2'b00;
localparam DATA=2'b01;
localparam PARITY=2'b10;
localparam STOP=2'b11;
reg [1:0] state=IDLE;
reg current_parity=1'b0;
reg par_err_internal = 1'b0;
always @ (posedge clk)
begin
if(reset==1'b0)
begin
 shift_reg<= 8'b0;
 count<= 4'b0;
 current_parity <= 1'b0;
 state<= IDLE;
 done<= 1'b0;
 parity_err<= 1'b0;
 frame_err<= 1'b0;
 data_out <= 8'b0;
 par_err_internal <= 1'b0;
end 
else
case (state) 
IDLE: begin
      done<=1'b0;
      parity_err<=1'b0;
      frame_err<=1'b0;
      data_out <= 8'b0;
      if (!stream)
      begin 
      state<=DATA;
      count <= 4'b0; 
      current_parity <= 1'b0;
      end
      end 
DATA: 
      begin
      shift_reg<={stream,shift_reg[7:1]};
      current_parity<=current_parity ^ stream;
      if(count==4'b111)
      begin
      count<=4'b0000;
      state<=PARITY;
      end       
      else 
      begin
      count<=count+1'b1;
      end 
      end 
PARITY: begin
      if(stream != current_parity) begin
      par_err_internal <= 1'b1;
      end 
      else
       begin
      par_err_internal <= 1'b0;
      end
      state <= STOP;
      end 

STOP: begin
      if(stream == 1'b0) begin 
      frame_err <= 1'b1;
      end 
      if(par_err_internal == 1'b1) begin
      parity_err <= 1'b1;
      end
      if(stream == 1'b1 && par_err_internal == 1'b0) begin 
      done <= 1'b1;
      data_out <= shift_reg;
      end
      else
      begin
      data_out <= 8'b0;
      end 
      state <= IDLE;
end
endcase
end
endmodule
