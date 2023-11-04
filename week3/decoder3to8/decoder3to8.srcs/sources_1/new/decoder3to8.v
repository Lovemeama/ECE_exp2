`timescale 1ns / 1ps
module decoder3to8(x, y, z, D);

input x, y, z;
output reg [7:0] D;

always @({x,y,z})
begin

case({x,y,z})
3'b000 : D = 8'b00000001;
3'b001 : D = 8'b00000010;
3'b010 : D = 8'b00000100;
3'b011 : D = 8'b00001000;
3'b100 : D = 8'b00010000;
3'b101 : D = 8'b00100000;
3'b110 : D = 8'b01000000;
3'b111 : D = 8'b10000000;
default : D = 8'b00000000;
endcase
end
endmodule
