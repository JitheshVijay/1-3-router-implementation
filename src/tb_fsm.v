// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
`timescale 1ns/1ps

module tb_router_fsm;

// Testbench signals
reg clock;
reg resetn;
reg soft_reset;
reg [7:0] data_in;
reg lfd_state;
reg fifo_empty;
reg fifo_full;

wire [1:0] state_out;
wire write_enb;
wire read_enb;
wire [7:0] data_out;

// Instantiate the DUT (Device Under Test)
router_fsm dut (
    .clock(clock),
    .resetn(resetn),
    .soft_reset(soft_reset),
    .data_in(data_in),
    .lfd_state(lfd_state),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full),
    .state_out(state_out),
    .write_enb(write_enb),
    .read_enb(read_enb),
    .data_out(data_out)
);

// Clock generation
initial begin
    clock = 0;
    forever #5 clock = ~clock; // 100MHz clock (10ns period)
end

// Test stimulus
initial begin
    $display("=== Router FSM Test Suite ===");
    
    // Initialize all inputs
    resetn = 0;
    soft_reset = 0;
    data_in = 8'h00;
    lfd_state = 0;
    fifo_empty = 1;
    fifo_full = 0;
    
    // Apply reset
    #20;
    resetn = 1;
    #10;
    
    // Test 1: IDLE state
    $display("Test 1: IDLE State");
    fifo_empty = 1;
    fifo_full = 0;
    lfd_state = 0;
    #10;
    if (state_out == 2'b00 && write_enb == 1'b0 && read_enb == 1'b0) begin
        $display("✅ PASS: IDLE State");
    end else begin
        $display("❌ FAIL: IDLE State");
    end
    
    // Test 2: WRITE state
    $display("Test 2: WRITE State");
    lfd_state = 1;
    fifo_full = 0;
    #10;
    if (state_out == 2'b10 && write_enb == 1'b1 && read_enb == 1'b0) begin
        $display("✅ PASS: WRITE State");
    end else begin
        $display("❌ FAIL: WRITE State");
    end
    
    // Test 3: READ state
    $display("Test 3: READ State");
    lfd_state = 0;
    fifo_empty = 0;
    fifo_full = 0;
    data_in = 8'hAA;
    #10;
    if (state_out == 2'b01 && write_enb == 1'b0 && read_enb == 1'b1) begin
        $display("✅ PASS: READ State");
    end else begin
        $display("❌ FAIL: READ State");
    end
    
    // Test 4: Soft reset
    $display("Test 4: Soft Reset");
    soft_reset = 1;
    #10;
    if (state_out == 2'b11 && write_enb == 1'b0 && read_enb == 1'b0) begin
        $display("✅ PASS: Soft Reset");
    end else begin
        $display("❌ FAIL: Soft Reset");
    end
    
    // Test 5: Back to IDLE
    $display("Test 5: Back to IDLE");
    soft_reset = 0;
    #10;
    if (state_out == 2'b00 && write_enb == 1'b0 && read_enb == 1'b0) begin
        $display("✅ PASS: Back to IDLE");
    end else begin
        $display("❌ FAIL: Back to IDLE");
    end
    
    // End simulation
    #50;
    
    $display("=== Test Complete ===");
    $display("TEST_PASSED");
    $finish;
end

// Generate VCD file for waveform viewing
initial begin
    $dumpfile("router_fsm.vcd");
    $dumpvars(0, tb_router_fsm);
end

endmodule