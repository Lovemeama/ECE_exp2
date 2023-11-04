`timescale 1ns / 1ps

module tbformux8to1();

    reg [3:0] I0, I1, I2, I3, I4, I5, I6, I7;
    reg S0, S1, S2;
    wire [3:0] Y;

mux8to1 tb (
        .I0(I0),
        .I1(I1),
        .I2(I2),
        .I3(I3),
        .I4(I4),
        .I5(I5),
        .I6(I6),
        .I7(I7),
        .S0(S0),
        .S1(S1),
        .S2(S2),
        .Y(Y)
);

initial begin
S0 = 1'b1;
S1 = 1'b0;
S2 = 1'b1;
                    
I0 = 4'b0000;
I1 = 4'b1111;
I2 = 4'b1100;
I3 = 4'b1010;
I4 = 4'b1001;
I5 = 4'b0110;
I6 = 4'b0101;
I7 = 4'b0011;

end
endmodule
