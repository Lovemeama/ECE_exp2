`timescale 1ns / 1ps


module tbfordflipflop();

reg clk, D;
wire Q;

dflipflop FF(clk, D, Q);

initial begin
clk <= 0;
#20 D <= 0;
#20 D <= 1;

#20 D <= 0;
#20 D <= 1;

#20 D <= 0;
#20 D <= 1;
end

always begin
#5 clk <= ~clk;
end
endmodule
