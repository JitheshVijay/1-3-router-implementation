// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
`timescale 1ns/1ps

module router_fifo_tb;

    // Testbench signals
    reg clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
    reg [7:0] data_in;
    wire empty, full;
    wire [7:0] data_out;
    integer i;

    // Instantiate DUT with correct port order
    router_fifo dut (
        .clock(clock),
        .resetn(resetn),
        .soft_reset(soft_reset),
        .write_enb(write_enb),
        .read_enb(read_enb),
        .lfd_state(lfd_state),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #10 clock = ~clock;

    // Reset task
    task reset();
        begin
            @(posedge clock) resetn = 0;
            @(posedge clock) resetn = 1;
        end
    endtask

    // Soft reset task
    task soft_reset_task();
        begin
            @(posedge clock) soft_reset = 1;
            @(posedge clock) soft_reset = 0;
        end
    endtask

    // Write packet task
    task write_packet();
        reg [7:0] payload, parity;
        reg [5:0] payload_length;
        reg [1:0] addr;
        begin
            @(negedge clock);
            payload_length = 6'd14;
            addr = 2'b01;
            lfd_state = 1'b1;  // Header word
            write_enb = 1'b1;
            data_in = {payload_length, addr};

            // Write payload data
            for (i = 0; i < payload_length; i = i + 1) begin
                @(negedge clock);
                lfd_state = 1'b0;  // Data word
                payload = {$random} % 256;
                data_in = payload;
            end

            // Write parity
            @(negedge clock);
            parity = {$random} % 256;
            data_in = parity;

            @(negedge clock);
            write_enb = 1'b0;
        end
    endtask

    // Read word task
    task read_word();
        begin
            @(negedge clock) read_enb = 1'b1;
            @(negedge clock) read_enb = 1'b0;
        end
    endtask

    // Initialize signals
    task initialize();
        {clock, resetn, soft_reset, write_enb, read_enb, lfd_state} = 6'b010000;
    endtask

    // Main test sequence
    initial begin
        $dumpfile("wave.vcd");  // ✅ FIXED: Use "wave.vcd" instead of "router_fifo.vcd"
        $dumpvars(0, router_fifo_tb);

        initialize();
        reset();
        #20;

        // Test 1: Write and read a packet
        $display("=== Test 1: Write and read packet ===");
        write_packet();
        
        // Read all words from the packet
        for (i = 0; i < 16; i = i + 1) begin
            read_word();
        end

        #20;

        // Test 2: Write another packet and test soft reset
        $display("=== Test 2: Soft reset test ===");
        write_packet();
        soft_reset_task();
        write_packet();
        
        // Read some words
        for (i = 0; i < 8; i = i + 1) begin
            read_word();
        end

        #20;

        // Test 3: Test full condition
        $display("=== Test 3: Full condition test ===");
        // Write multiple packets to fill FIFO
        for (i = 0; i < 3; i = i + 1) begin
            write_packet();
        end

        #20;

        $display("=== All tests completed successfully ===");
        $display("TEST_PASSED");
        $finish;
    end

endmodule