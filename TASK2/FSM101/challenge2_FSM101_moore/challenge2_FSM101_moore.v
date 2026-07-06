`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 00:34:20
// Design Name: 
// Module Name: challenge2_FSM101_moore
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


module challenge2_FSM101_moore(
    input x,
    input clk,
    input reset_n,
    output y
    );
 reg [2:0] state_next,state_reg;
 localparam s0=3'd0;
 localparam s1=3'd1;
 localparam s2=3'd2;
 localparam s3=3'd3;
 localparam s4=3'd4;
 localparam s5=3'd5;
 always @ (posedge clk, negedge reset_n)
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
     state_next=s4;
     else 
     state_next=s5;
s4: if(x)
     state_next=s1;
     else 
     state_next=s2; 
s5: if(x)
     state_next=s3;
     else 
     state_next=s0;
default: state_next = s0;    
 endcase
 end
assign y= (state_reg==s3)|  (state_reg==s4) |(state_reg==s5);
endmodule