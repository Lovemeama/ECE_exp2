`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 16:46:33
// Design Name: 
// Module Name: half_adder_with_case
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module half_adder_with_case(a, b, c, s);

  input a, b;
  output c, s;

  reg c, s;

  always @(a)
  case(a)
  2'b00 : begin 
  s = 0;
  c = 0;
  end
  2'b01 : begin 
  s = 1;
  c = 0;
  end
  2'b10 : begin
  s = 1;
  c = 0;
  end
  2'b11 : begin
  s = 0;
  c = 1;
  end
  endcase
  endmodule