`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 16:31:36
// Design Name: 
// Module Name: half_adder
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


module half_adder(a, b, c,s);

input a, b;
output c,s;

assign c = a & b; // and
assign s = a ^ b; // xor

endmodule

module full_adder (a,b, cin, cout, sum);
input a, b, cin;
output sum, cout;

wire s1, s2, c1, c2;

half_adder ha1(a, b, s1, c1);
half_adder ha2(s1, cin, sum, c2);
assign cout = c1 | c2;

endmodule