`timescale 1ns / 1ps

module tb_command_reciever();

    // Inputs
    reg stream;
    reg clk;
    reg reset;

    // Outputs
    wire done;
    wire parity_err;
    wire frame_err;
    wire [7:0] result;

    command_reciever uut (
        .stream(stream), 
        .clk(clk), 
        .reset(reset), 
        .done(done), 
        .parity_err(parity_err), 
        .frame_err(frame_err), 
        .result(result)
    );

    //Clock Generation
    always #5 clk = ~clk;

    // automatically build and send packets
    task send_cmd_packet(input [1:0] cmd, input [7:0] data, input bad_parity, input bad_frame);
        integer i;
        reg calc_parity;
        begin
            calc_parity = 1'b0; // Reset parity calculator
            
            // 1. Send Start Bit (0)
            stream = 1'b0; 
            #10;
            
            // 2. Send 2 Command Bits 
            for (i = 0; i < 2; i = i + 1) begin
                stream = cmd[i];
                #10;
            end
            
            // 3. Send 8 Data Bits 
            for (i = 0; i < 8; i = i + 1) begin
                stream = data[i];
                calc_parity = calc_parity ^ data[i];
                #10;
            end
            
            // 4. Send Even Parity Bit
            stream = bad_parity ? ~calc_parity : calc_parity;
            #10;
            
            // 5. Send Stop Bit
            stream = bad_frame ? 1'b0 : 1'b1;
            #10;
            
            // 6. Return to IDLE
            stream = 1'b1; 
            #40; 
            end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0; 
        stream = 1; 
        reset = 0;
        // Apply Active-Low Reset
        #20 reset = 1; 
        #20;

        $display(" 1. Testing LOAD_A (00) with Data = 15 ");
        // cmd = 00, data = 15 (00001111)
        send_cmd_packet(2'b00, 8'd15, 0, 0);

        $display(" 2. Testing LOAD_B (01) with Data = 25 ");
        // cmd = 01, data = 25 (00011001)
        send_cmd_packet(2'b01, 8'd25, 0, 0);

        $display(" 3. Testing ADD (10) Command (Expect Result = 40) ");
        // cmd = 10
        send_cmd_packet(2'b10, 8'd0, 0, 0);

        $display(" 4. Testing CLEAR (11) Command (Expect Result = 0) ");
        // cmd = 11, should wipe A and B to 0
        send_cmd_packet(2'b11, 8'd0, 0, 0);
        
        $display(" 5. Testing Error Handling: Parity Error on LOAD_A ");
        // Should flag parity_err and NOT update the result
        send_cmd_packet(2'b00, 8'd50, 1, 0);
        
        #50;      
        $display(" Simulation Complete ");
        $finish;
    end

endmodule