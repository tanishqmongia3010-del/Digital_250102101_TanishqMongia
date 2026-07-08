`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 15:45:27
// Design Name: 
// Module Name: testbench
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


`timescale 1ns / 1ps

module tb_framepacketreceiver;

    // Inputs
    reg stream;
    reg clk;
    reg reset;

    // Outputs
    wire done;
    wire parity_err;
    wire frame_err;
    wire [7:0] data_out;

    framepacketreceiver u1 (
        .stream(stream), 
        .clk(clk), 
        .reset(reset), 
        .done(done), 
        .parity_err(parity_err), 
        .frame_err(frame_err), 
        .data_out(data_out)
    );

    //  Clock Generation
    always #5 clk = ~clk;

    // Task to  send packets 
    task send_packet(input [7:0] data, input inject_parity_err, input inject_frame_err);
        integer i;
        reg calc_parity;
        begin
            calc_parity = 1'b0;
            
            // 1. Send Start Bit (0)
            stream = 1'b0; 
            #10;
            
            // 2. Send 8 Data Bits 
            for (i = 0; i < 8; i = i + 1) begin
                stream = data[i];
                calc_parity = calc_parity ^ data[i];
                #10;
            end
            
            // 3. Send Parity Bit 
            stream = inject_parity_err ? ~calc_parity : calc_parity;
            #10;
            
            // 4. Send Stop Bit (1 for valid, 0 for frame error)
            stream = inject_frame_err ? 1'b0 : 1'b1;
            #10;
            
            // 5. Return to IDLE
            stream = 1'b1;
            #30; 
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        stream = 1; // Default IDLE state
        reset = 0;  // Active-Low Reset

        // Release Reset
        #20 reset = 1;
        #10;

        $display("Test 1: Valid Packet ");
        send_packet(8'hAA, 0, 0);

        $display("Test 2: Parity Error Packet ");
        send_packet(8'h55, 1, 0);

        $display("Test 3: Frame Error Packet");
        send_packet(8'h3C, 0, 1);
        
        $display(" Test 4: Valid Packet");
        send_packet(8'hFF, 0, 0);

        $finish;
    end

endmodule
