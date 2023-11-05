`timescale 1ns / 1ps

module tb_binary_to_bcd();

  reg clk;
  reg rst;
  reg [3:0] bin;
  wire [7:0] bcd;

  binary_to_bcd tb(
    .clk(clk),
    .rst(rst),
    .bin(bin),
    .bcd(bcd)
  );

  always begin
    #5 clk = ~clk;
  end

  initial begin
    clk = 0;
    rst = 1;
    bin = 0;
    #10 rst = 0;
    #10 rst = 1;
  end

  initial begin
 
    bin = 7;
    #25;
    bin = 13;
    #25;
    bin = 8;
    #25;
    bin = 9;
    #25;
    bin = 15;
    #10;

    $finish;
  end

endmodule
