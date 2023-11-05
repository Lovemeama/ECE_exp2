`timescale 1ns / 1ps

module tb_7array();

  reg clk, rst;
  reg btn;
  wire [7:0] seg_data;
  wire [7:0] seg_sel;

  seg_array tb (clk, rst, btn, seg_data, seg_sel);

  always begin
    #5 clk = ~clk;
  end

  initial begin
    clk <= 0;
    rst <= 1;
    btn <= 0;
    #10 rst <= 0;
    #10 rst <= 1;
  end

  initial begin
    // Test case 1: Button trigger
    btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
    #30 btn <= 1;
    #30 btn <= 0;
     
    
  end
endmodule