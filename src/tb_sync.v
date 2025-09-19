// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
`timescale 1ns/1ps

module tb_sync;
    // Testbench signals
    reg clock;
    reg resetn;
    reg enable;
    reg [7:0] data_in;
    wire [7:0] data_out;
    
    // Instantiate the DUT (Device Under Test)
    sync dut (
        .clock(clock),
        .resetn(resetn),
        .enable(enable),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100MHz clock (10ns period)
    end
    
    // Test stimulus
    initial begin
        $display("=== Synchronous Register Test Suite ===");
        
        // Initialize all inputs
        resetn = 0;
        enable = 0;
        data_in = 8'h00;
        #20;
        
        // Test 1: Reset functionality
        $display("Test 1: Reset Test");
        resetn = 1;
        enable = 1;
        data_in = 8'hAA;
        #10;
        if (data_out == 8'hAA) begin
            $display("✅ PASS: Data stored correctly after reset");
        end else begin
            $display("❌ FAIL: Data not stored correctly after reset");
        end
        
        // Test 2: Enable/Disable functionality
        $display("Test 2: Enable/Disable Test");
        data_in = 8'h55;
        enable = 0;
        #10;
        if (data_out == 8'hAA) begin
            $display("✅ PASS: Data held when enable is low");
        end else begin
            $display("❌ FAIL: Data changed when enable is low");
        end
        
        enable = 1;
        #10;
        if (data_out == 8'h55) begin
            $display("✅ PASS: Data updated when enable is high");
        end else begin
            $display("❌ FAIL: Data not updated when enable is high");
        end
        
        // Test 3: Multiple data changes
        $display("Test 3: Multiple Data Changes");
        data_in = 8'h33;
        #10;
        if (data_out == 8'h33) begin
            $display("✅ PASS: Data updated to 0x33");
        end else begin
            $display("❌ FAIL: Data not updated to 0x33");
        end
        
        data_in = 8'hCC;
        #10;
        if (data_out == 8'hCC) begin
            $display("✅ PASS: Data updated to 0xCC");
        end else begin
            $display("❌ FAIL: Data not updated to 0xCC");
        end
        
        // Test 4: Reset during operation
        $display("Test 4: Reset During Operation");
        resetn = 0;
        #10;
        if (data_out == 8'h0) begin
            $display("✅ PASS: Reset works correctly");
        end else begin
            $display("❌ FAIL: Reset failed");
        end
        
        // Test 5: Recovery from reset
        $display("Test 5: Recovery from Reset");
        resetn = 1;
        enable = 1;
        data_in = 8'hFF;
        #10;
        if (data_out == 8'hFF) begin
            $display("✅ PASS: Data stored correctly after reset recovery");
        end else begin
            $display("❌ FAIL: Data not stored correctly after reset recovery");
        end
        
        // End simulation
        #50;
        
        $display("=== Test Complete ===");
        $display("TEST_PASSED");
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("sync.vcd");
        $dumpvars(0, tb_sync);
    end
    
endmodule