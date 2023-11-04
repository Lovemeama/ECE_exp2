`timescale 1ns / 1ps
module encoder4to2 (a, b);
input [3:0] a;
output reg [1:0] b;

always @(*) begin
casex(a)
4'b0001: b = 2'b00;
4'b001x: b = 2'b01;
4'b01xx: b = 2'b10;
4'b1xxx: b = 2'b11;
default: b = 2'b00; 
endcase
end
endmodule