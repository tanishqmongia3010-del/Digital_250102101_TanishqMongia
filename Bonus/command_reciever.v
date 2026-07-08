`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 14:19:45
// Design Name: 
// Module Name: command_reciever
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


module command_reciever(
input stream,
input clk,
input reset ,
output reg done,
output reg parity_err,
output reg  frame_err,
output reg [7:0] result
    );
// internal registers 
 reg [7:0] A=8'b0,B=8'b0;
reg [1:0] shift_reg1;
reg [7:0] shift_reg2;
reg [3:0] count ;
reg current_parity=1'b0;
reg par_err_internal = 1'b0;
// states of fsm for receiving the packets 
localparam IDLE=3'b000;
localparam COMMAND=3'b001;
localparam DATA=3'b010;
localparam PARITY=3'b011;
localparam STOP=3'b100 ;
//commands
localparam LOAD_A=2'b00;
localparam LOAD_B=2'b01;
localparam ADD=2'b10;
localparam CLEAR=2'b11;

reg [2:0] state=IDLE;

always @ (posedge clk)

begin
if(reset==1'b0)
begin
 shift_reg1<=2'b0;
 shift_reg2<= 8'b0;
 count<= 4'b0;
 current_parity <= 1'b0;
 state<= IDLE;
 done<= 1'b0;
 parity_err<= 1'b0;
 frame_err<= 1'b0;
 result <= 8'b0;
 par_err_internal <= 1'b0;
 A <= 8'b0;
 B <= 8'b0;
end 
else
begin
case (state) 
IDLE: begin
      done<=1'b0;
      parity_err<=1'b0;
      frame_err<=1'b0;
      result<=8'b0;
      if (!stream)
      begin 
      state<=COMMAND;
      count <= 4'b0; 
      current_parity <= 1'b0;
      end
      end
      
COMMAND:begin
        shift_reg1<={stream,shift_reg1[1:1]};
        if(count==4'b0001)
        begin
        count<=4'b0000;
        state<=DATA;
        end 
        else
        count<=count+4'b0001;
        end 
        
DATA: 
      begin
      shift_reg2 <={stream,shift_reg2[7:1]};
      current_parity<=current_parity ^ stream;
      if(count==4'b111)
      begin
      count<=4'b0000;
      state<=PARITY;
      end       
      else 
      begin
      count<=count+4'b0001;
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
        case (shift_reg1)
               LOAD_A: begin
                A <= shift_reg2;
                result <= shift_reg2;
                end 
                LOAD_B: begin
                B <= shift_reg2;
                result <= shift_reg2;
                end 
                ADD: begin  
                result <= A + B;
                end
                CLEAR: begin
                 A <= 8'b0;        
                 B <= 8'b0;
                 result <= 8'b0;
                 end            
        endcase
        end 
        else
        begin 
        result <= 8'b0;
        end 
        state <= IDLE;
end
default: state<=IDLE;
endcase 
end
end
endmodule
