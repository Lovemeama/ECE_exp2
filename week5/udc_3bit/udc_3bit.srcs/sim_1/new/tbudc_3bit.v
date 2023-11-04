`timescale 1ns / 1ps
module tb_udcounter3bit();

reg clk, rst, x;
wire [2:0] state;

udc_3bit tb(clk, rst, x, state);

 always begin
    #5 clk <= ~clk;
 end
 
initial begin
    clk <=0;
    rst <=1;
    x <= 0;
    #10 rst <= 0;
    #10 rst <= 1;
    
    #10 x <= 1;
    #10 x <= 0; // 001
    #10 x <= 1;
    #10 x <= 0; // 010
    #10 x <= 1;
    #10 x <= 0; // 011
    #10 x <= 1;
    #10 x <= 0; // 100
    #10 x <= 1;
    #10 x <= 0; // 101
    #10 x <= 1;
    #10 x <= 0; // 110
    #10 x <= 1;
    #10 x <= 0; // 111
    #10 x <= 1;
    #10 x <= 0; // 110
    #10 x <= 1;
    #10 x <= 0; // 101
    #10 x <= 1;
    #10 x <= 0; // 100
    #10 x <= 1;
    #10 x <= 0; // 011
    #10 x <= 1;
    #10 x <= 0; // 010
    #10 x <= 1;
    #10 x <= 0; // 001
    #10 x <= 1;
    #10 x <= 0; // 000
    #10 x <= 1;
    #10 x <= 0; // 001 
    
    #10 x <= 1;
    #10 x <= 0; // 010
    #10 x <= 1;
    #10 x <= 0; // 011
    #10 x <= 1;
    #10 x <= 0; // 100
    
    #20 $finish;   
 end
 endmodule  