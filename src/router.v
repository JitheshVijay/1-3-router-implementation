// Copyright Refringence
// Built with Refringence IDE — https://refringence.com
// src/router.v (self-contained 1x3 router; no submodules)
`timescale 1ns/1ps
module router(
  input         clock, input resetn,
  input         pkt_valid, input [7:0] data_in,
  input         read_enb_0, input read_enb_1, input read_enb_2,
  output [7:0]  data_out_0, output [7:0] data_out_1, output [7:0] data_out_2,
  output        vld_out_0,  output vld_out_1,  output vld_out_2,
  output        err, output busy
);
  // tiny FIFOs (depth 8) per port
  reg [7:0] q0[0:7], q1[0:7], q2[0:7];
  reg [2:0] w0,r0,c0, w1,r1,c1, w2,r2,c2;

  // simple packet receiver
  reg [1:0] dest; reg [5:0] remaining;
  reg in_pkt; reg [7:0] parity_acc; reg err_r; reg busy_r;
  assign err=err_r; assign busy=busy_r;

  wire v0 = (c0!=0), v1 = (c1!=0), v2 = (c2!=0);
  assign vld_out_0=v0; assign vld_out_1=v1; assign vld_out_2=v2;
  assign data_out_0 = v0 ? q0[r0] : 8'h00;
  assign data_out_1 = v1 ? q1[r1] : 8'h00;
  assign data_out_2 = v2 ? q2[r2] : 8'h00;

  // pop on read enable
  always @(posedge clock or negedge resetn) begin
    if(!resetn) begin r0<=0;c0<=0; r1<=0;c1<=0; r2<=0;c2<=0; end
    else begin
      if(read_enb_0 && v0) begin r0<=r0+1'b1; c0<=c0-1'b1; end
      if(read_enb_1 && v1) begin r1<=r1+1'b1; c1<=c1-1'b1; end
      if(read_enb_2 && v2) begin r2<=r2+1'b1; c2<=c2-1'b1; end
    end
  end

  // packet ingest: header -> payload bytes while pkt_valid=1 -> parity when pkt_valid=0
  always @(posedge clock or negedge resetn) begin
    if(!resetn) begin
      in_pkt<=1'b0; remaining<=6'd0; parity_acc<=8'h00; err_r<=1'b0; busy_r<=1'b0;
      w0<=0;w1<=0;w2<=0; c0<=0;c1<=0;c2<=0; r0<=0;r1<=0;r2<=0;
    end else begin
      err_r<=1'b0;

      if(!in_pkt && pkt_valid) begin
        // header
        dest <= data_in[1:0];
        remaining <= data_in[7:2];
        parity_acc <= data_in;
        in_pkt <= 1'b1;
        busy_r <= 1'b1;
      end else if(in_pkt) begin
        if(pkt_valid) begin
          // payload byte
          parity_acc <= parity_acc ^ data_in;
          if(remaining != 0) begin
            case(dest)
              2'd0: begin q0[w0] <= data_in; w0<=w0+1'b1; c0<=c0+1'b1; end
              2'd1: begin q1[w1] <= data_in; w1<=w1+1'b1; c1<=c1+1'b1; end
              default: begin q2[w2] <= data_in; w2<=w2+1'b1; c2<=c2+1'b1; end
            endcase
            remaining <= remaining - 1'b1;
          end
        end else begin
          // parity phase (pkt_valid == 0): compare then finish
          // If you want parity checking, compare here: err_r <= (parity_acc != data_in);
          in_pkt <= 1'b0;
          busy_r <= 1'b0;
        end
      end
    end
  end
endmodule