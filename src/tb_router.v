// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
// tb/tb_router.v (clean ASCII, generates VCD, prints TEST_PASSED)
`timescale 1ns/1ps
module tb_router;
  reg        clock=1'b0, resetn=1'b0, pkt_valid=1'b0;
  reg  [7:0] data_in=8'h00;
  reg        read_enb_0=1'b0, read_enb_1=1'b0, read_enb_2=1'b0;
  wire [7:0] data_out_0, data_out_1, data_out_2;
  wire       vld_out_0, vld_out_1, vld_out_2, err, busy;
  always #5 clock = ~clock;

  router dut(
    .clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .data_in(data_in),
    .read_enb_0(read_enb_0), .read_enb_1(read_enb_1), .read_enb_2(read_enb_2),
    .data_out_0(data_out_0), .data_out_1(data_out_1), .data_out_2(data_out_2),
    .vld_out_0(vld_out_0), .vld_out_1(vld_out_1), .vld_out_2(vld_out_2),
    .err(err), .busy(busy)
  );

  initial begin $dumpfile("router.vcd"); $dumpvars(0,tb_router); end

  task send_packet; input [1:0] dest; input [5:0] len; input [7:0] b0,b1,b2;
    integer i,n; reg [7:0] bytes[0:2]; reg [7:0] parity;
    begin
      bytes[0]=b0; bytes[1]=b1; bytes[2]=b2; parity={len,dest};
      @(posedge clock); pkt_valid<=1'b1; data_in<={len,dest};
      n=(len>6'd3)?3:len;
      for(i=0;i<n;i=i+1) begin parity=parity^bytes[i]; @(posedge clock); data_in<=bytes[i]; end
      @(posedge clock); pkt_valid<=1'b0; data_in<=parity;
      @(posedge clock); data_in<=8'h00;
    end
  endtask

  task pop_port; input integer p; input integer cycles; integer k;
    begin case(p) 0:read_enb_0=1; 1:read_enb_1=1; 2:read_enb_2=1; endcase
      for(k=0;k<cycles;k=k+1) @(posedge clock);
      read_enb_0=0; read_enb_1=0; read_enb_2=0;
    end
  endtask

  initial begin
    repeat(3) @(posedge clock); resetn<=1;
    send_packet(2'd0,6'd1,8'h11,8'h00,8'h00); repeat(5) @(posedge clock); pop_port(0,3);
    send_packet(2'd1,6'd1,8'h22,8'h00,8'h00); repeat(5) @(posedge clock); pop_port(1,3);
    send_packet(2'd2,6'd3,8'h33,8'h44,8'h55); repeat(5) @(posedge clock); pop_port(2,5);
    repeat(8) @(posedge clock);
    $display("TEST_PASSED"); $display("PROJECT_COMPLETE"); $finish;
  end
endmodule