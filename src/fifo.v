// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
`timescale 1ns/1ps

module router_fifo(
    input clock,
    input resetn,
    input soft_reset,
    input write_enb,
    input read_enb,
    input lfd_state,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output full,
    output empty
);

    // Internal signals
    reg [8:0] mem [0:15];  // 9-bit memory (1 bit header + 8 bit data)
    reg [4:0] wr_ptr;      // Write pointer
    reg [4:0] read_ptr;    // Read pointer
    reg [6:0] counter;     // Packet length counter
    reg lfd_s;             // LFD state register
    integer i;

    // LFD state register
    always @(posedge clock) begin
        if (resetn == 1'b0)
            lfd_s <= 1'b0;
        else
            lfd_s <= lfd_state;
    end

    // Write operation
    always @(posedge clock) begin
        if (resetn == 1'b0) begin
            // Reset all memory locations
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= 9'h0;
            end
            wr_ptr <= 5'b0;
        end
        else if (soft_reset == 1'b1) begin
            // Soft reset - clear memory
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= 9'h0;
            end
            wr_ptr <= 5'b0;
        end
        else if (write_enb == 1'b1 && full == 1'b0) begin
            // Write data with header bit
            mem[wr_ptr[3:0]] <= {lfd_s, data_in};
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // Read operation
    always @(posedge clock) begin
        if (resetn == 1'b0) begin
            data_out <= 8'h0;
            read_ptr <= 5'b0;
        end
        else if (soft_reset == 1'b1) begin
            data_out <= 8'hz;  // High impedance during soft reset
            read_ptr <= 5'b0;
        end
        else if (read_enb == 1'b1 && empty == 1'b0) begin
            // Read data (without header bit)
            data_out <= mem[read_ptr[3:0]][7:0];
            read_ptr <= read_ptr + 1'b1;
        end
        else if (!full && empty && counter == 1'b0) begin
            data_out <= 8'hz;  // High impedance when empty
        end
        else begin
            data_out <= data_out;  // Hold previous value
        end
    end

    // Counter logic for packet length tracking
    always @(posedge clock) begin
        if (resetn == 1'b0) begin
            counter <= 7'b0;
        end
        else if (soft_reset == 1'b1) begin
            counter <= 0;
        end
        else if (lfd_s == 1'b1) begin
            // Load counter from header (bits 7:2 of first word)
            counter <= mem[read_ptr[3:0]][7:2] + 1'b1;
        end
        else if (read_enb == 1'b1) begin
            if (mem[read_ptr[3:0]][8] == 1'b1) begin
                // Header word - don't decrement counter
                counter <= counter;
            end
            else begin
                // Data word - decrement counter
                counter <= counter - 1'b1;
            end
        end
    end

    // Full and empty flags
    assign full = (wr_ptr == {~read_ptr[4], read_ptr[3:0]});
    assign empty = (wr_ptr == read_ptr);

endmodule