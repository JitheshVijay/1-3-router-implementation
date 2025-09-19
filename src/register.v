// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
module router_register(
    input clock,
    input resetn,
    input enable,
    input [7:0] data_in,
    output reg [7:0] data_out
);
    always @(posedge clock) begin
        if (!resetn) begin
            data_out <= 8'h0;
        end else if (enable) begin
            data_out <= data_in;
        end
        // If enable is low, data_out holds its current value
    end
endmodule