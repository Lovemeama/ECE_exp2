`timescale 1ns / 1ps
`timescale 1ns / 1ps

module tbvm;
    reg clk;
    reg rst;
    reg A, B, C;
    wire [2:0] state;
    wire y;

    vending_machine tb(
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .C(C),
        .state(state),
        .y(y)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
    clk <= 0;
    rst <= 1;
    A <= 0;
    B <= 0;
    C <= 0;
    #10 rst <= 0;
    #10 rst <= 1;
    #50 A <= 1; // S50
    #20 A <= 0;
    #50 B <= 1; // S150
    #20 B <= 0;
    #50 A <= 1; // S200
    #20 A <= 0;
    #50 B <= 1; // S200
    #20 B <= 0;
    #50 C <= 1; // y = 1
    #80 C <= 0;
    #10 rst <= 0;
    #10 rst <= 1; // reset S0
    #50 A <= 1; // S50
    #20 A <= 0;
    #50 B <= 1; // S150
    #20 B <= 0;
    #50 C <= 1; // S150 
    
    #40
    $finish;
end


endmodule