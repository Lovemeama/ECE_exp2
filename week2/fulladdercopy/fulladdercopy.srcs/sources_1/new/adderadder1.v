`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 18:13:38
// Design Name: 
// Module Name: adderadder1
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


//Half adder using data flow modeling
module half_adder (
    input a,b,
    output sum,carry
);

assign sum = a ^ b;
assign carry = a & b;

endmodule

//Full adder using half adder
module full_adder(
    input a,b,cin,
    output sum,carry
);

wire c,c1,s;

half_adder ha0(a,b,s,c);
half_adder ha1(cin,s,sum,c1);

assign carry = c | c1 ;

endmodule