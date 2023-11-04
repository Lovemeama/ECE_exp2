`timescale 1ns / 1ps
module tbfor4bitcomparator();
reg [3:0] a, b;
wire x, y, z;

comparator_4bit tb(
.a(a),
.b(b),
.x(x),
.y(y),
.z(z)
);

initial begin
a = 4'b0011;
b = 4'b0001;
end
endmodule
