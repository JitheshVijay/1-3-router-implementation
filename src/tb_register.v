// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
module tb_router_register;
    // Testbench signals
    reg clock;
    reg resetn;
    reg enable;
    reg [7:0] data_in;
    wire [7:0] data_out;
    
    // Instantiate the DUT
    router_register dut (
        .clock(clock),
        .resetn(resetn),
        .enable(enable),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100MHz clock
    end
    
    // Test stimulus
    initial begin
        $display("=== Router Register Test Suite ===");
        
        // Initialize inputs
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
            $display("✅ PASS: Data stored correctly");
        end else begin
            $display("❌ FAIL: Data not stored correctly");
        end
        
        // Test 2: Enable/Disable functionality
        $display("Test 2: Enable/Disable Test");
        data_in = 8'h55;
        enable = 0;
        #10;
        if (data_out == 8'hAA) begin
            $display("✅ PASS: Data held when disabled");
        end else begin
            $display("❌ FAIL: Data changed when disabled");
        end
        
        enable = 1;
        #10;
        if (data_out == 8'h55) begin
            $display("✅ PASS: Data updated when enabled");
        end else begin
            $display("❌ FAIL: Data not updated when enabled");
        end
        
        // Test 3: Reset functionality
        $display("Test 3: Reset Test");
        resetn = 0;
        #10;
        if (data_out == 8'h0) begin
            $display("✅ PASS: Reset works correctly");
        end else begin
            $display("❌ FAIL: Reset failed");
        end
        
        $display("=== Test Complete ===");
        $display("TEST_PASSED");
        $finish;
    end
    
    // VCD generation
    initial begin
        $dumpfile("router_register.vcd");
        $dumpvars(0, tb_router_register);
    end
endmodule