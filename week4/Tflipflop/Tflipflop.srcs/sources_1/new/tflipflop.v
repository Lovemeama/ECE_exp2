`timescale 1ns / 1ps
module tflipflop(clk, rst, T, Q);
input T, clk, rst;
output reg Q;

always @(posedge clk or negedge rst) begin
if (!rst)
   Q <= 1'b0;
else if(T)
   Q <= ~Q;
end
endmodule
