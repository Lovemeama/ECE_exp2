`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 14:02:48
// Design Name: 
// Module Name: logic_gate
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


module logic_gate (a, b, x, y, z, l, m);

input a, b;

output x, y, z, l, m;

wire x, y, z, l, m;

assign x = a & b; // and gate
assign y = a | b; // or gate
assign z = a ^ b; // xor gate
assign l = ~(a | b); // nor gate
assign m = ~(a & b); // nand gate

endmodule