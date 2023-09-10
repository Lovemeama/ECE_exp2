module fulladdertestbench();

reg [1:0] a, b, cin;
wire cout, sum;

full_adder tb(
.a(a),
.b(b),
.cin(cin),
.cout(cout),
.sum(sum)
);

initial begin
a = 0;
b = 0;
cin = 0;
#100;

a = 0;
b = 0;
cin = 1;
#100;

a = 0;
b = 1;
cin = 0;
#100;

a = 0;
b = 1;
cin = 1;
#100;

a = 1;
b = 0;
cin = 0;
#100;

a = 1;
b = 0;
cin = 1;
#100;

a = 1;
b = 1;
cin = 0;
#100;

a = 1;
b = 1;
cin = 1;
#100;

$finish;

end
endmodule