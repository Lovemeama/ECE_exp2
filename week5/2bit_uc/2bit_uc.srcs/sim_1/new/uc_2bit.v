`timescale 1ns / 1ps
`timescale 1ns / 1ps

module uc_2bit;
    reg clk;
    reg rst;
    reg x;
    wire [1:0] state;

    bit_uc tb(
        .clk(clk),
        .rst(rst),
        .x(x),
        .state(state)
    );

    always begin
        #5 clk <= ~clk;
    end

    initial begin
        clk <= 0;
        rst <= 1;
        x <= 0;
        #10 rst <= 0;
        #10 rst <= 1;
        #10 x <= 1;
        #10 x <= 0;
        #10 x <= 1;
        #10 x <= 0;
        #10 x <= 1;
        #10 x <= 0;
        #10 x <= 1;
        #10 x <= 1;
        #10 x <= 0;
        #10 x <= 1;
        #10 x <= 0;
        #10 x <= 1;

        #10 $finish;
    end
endmodule

