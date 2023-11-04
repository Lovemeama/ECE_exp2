`timescale 1ns / 1ps

module tbforencoder4to2();
reg [3:0] a;
wire [1:0] b;

encoder4to2 tb(
.a(a),
.b(b)
);

initial begin
a = 4'b0001;
end
endmodule