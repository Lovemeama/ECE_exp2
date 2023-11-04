`timescale 1ns / 1ps
module tbfortflipflop();
reg clk, rst, T;
wire Q;

tflipflop FF (clk, rst, T, Q);

initial begin
   clk <= 0;
   rst <= 1;
   T <= 0;
   #10 rst <= 0;
   #10 rst <= 1;
   #30 T <= 1;
   #30 T <= 0;
   #30 T <= 1;
   #30 T <= 0;
   #30 T <= 1;
end

always begin
#5 clk <= ~clk;
end
endmodule
