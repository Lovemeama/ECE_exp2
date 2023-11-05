`timescale 1us / 1ns
module tb_piezo();

reg clk, rst;
reg [7:0] btn;
wire piz;

piezo tb (clk, rst, btn, piz);

initial begin
clk <= 0;
rst <= 1;
btn <= 8'b00000000;
#1e+6; rst <= 0;
#1e+6; rst <= 1;
#1e+6; btn <= 8'b00000010;
#1e+6; btn <= 8'b00100000;
end

always begin
  #0.25 clk <= ~clk;
end 
endmodule
