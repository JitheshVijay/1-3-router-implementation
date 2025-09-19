// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
`timescale 1ns/1ps

$0
module router_fsm(
    input wire clock,
    input wire resetn,
    input wire soft_reset,
    input wire [7:0] data_in,
    input wire lfd_state,
    input wire fifo_empty,
    input wire fifo_full,
    output reg [1:0] state_out,
    output reg write_enb,
    output reg read_enb,
    output reg [7:0] data_out
);

// State definitions using parameter
parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter WRITE = 2'b10;
parameter RESET = 2'b11;

// State registers
reg [1:0] current_state, next_state;

// State machine logic
always @(posedge clock or negedge resetn) begin
    if (!resetn || soft_reset) begin
        current_state <= RESET;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        IDLE: begin
            if (lfd_state && !fifo_full) begin
                next_state = WRITE;
            end else if (!fifo_empty) begin
                next_state = READ;
            end else begin
                next_state = IDLE;
            end
        end
        
        READ: begin
            if (lfd_state && !fifo_full) begin
                next_state = WRITE;
            end else begin
                next_state = IDLE;
            end
        end
        
        WRITE: begin
            if (!fifo_empty) begin
                next_state = READ;
            end else begin
                next_state = IDLE;
            end
        end
        
        RESET: begin
            next_state = IDLE;
        end
        
        default: begin
            next_state = IDLE;
        end
    endcase
end

// Output logic - FIXED: Don't reset data_out unnecessarily
always @(*) begin
    case (current_state)
        IDLE: begin
            state_out = 2'b00;
            write_enb = 1'b0;
            read_enb = 1'b0;
            // Don't reset data_out in IDLE - keep previous value
        end
        
        READ: begin
            state_out = 2'b01;
            write_enb = 1'b0;
            read_enb = 1'b1;
            data_out = data_in; // Pass through data_in
        end
        
        WRITE: begin
            state_out = 2'b10;
            write_enb = 1'b1;
            read_enb = 1'b0;
            data_out = data_in; // Pass through data_in
        end
        
        RESET: begin
            state_out = 2'b11;
            write_enb = 1'b0;
            read_enb = 1'b0;
            data_out = 8'b0; // Only reset data_out in RESET state
        end
        
        default: begin
            state_out = 2'b00;
            write_enb = 1'b0;
            read_enb = 1'b0;
            // Don't reset data_out in default case
        end
    endcase
end

endmodule