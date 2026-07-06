`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 00:52:38
// Design Name: 
// Module Name: challenge2_FSM101_mealy
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


module challenge2_FSM101_mealy(
    input x,
    input clk,
    input reset_n,
    output y
    );
 reg [1:0] state_next,state_reg;
 localparam s0=2'd0;
 localparam s1=2'd1;
 localparam s2=2'd2;
 localparam s3=2'd3;
 always @(posedge clk,negedge reset_n)
 begin 
  if (!reset_n)
 state_reg<=s0;
 else
 state_reg<=state_next;
 end 
 
 always @ (*)
 begin
 case(state_reg)
s0: if(x)
     state_next=s1;
     else 
     state_next=s0;
s1: if(x)
     state_next=s1;
     else 
     state_next=s2;
s2: if(x)
     state_next=s3;
     else 
     state_next=s0;
s3: if(x)
     state_next=s1;
     else 
     state_next=s2;    
 endcase
 end
assign y= ((state_reg==s2)&x)|(state_reg==s3);
endmodule
