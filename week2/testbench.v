module testbench();

reg [1:0] a, b;
wire x, y, z, l, m;

logic_gate tb(
    .a(a),
    .b(b),
    .x(x),
    .y(y),
    .z(z),
    .l(l),
    .m(m)
  );

initial begin
    a = 1'b0;
    b = 1'b0;
    #10;

    a = 1'b0;
    b = 1'b1;
    #10;

    a = 1'b1;
    b = 1'b0;
    #10;

    a = 1'b1;
    b = 1'b1;
    #10;

    // 시뮬레이션 종료
    $finish;
end
endmodule