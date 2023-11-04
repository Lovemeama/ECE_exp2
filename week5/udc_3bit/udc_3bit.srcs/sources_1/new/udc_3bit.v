`timescale 1ns / 1ps
module udc_3bit(clk, rst, x, state);

input clk, rst;
input x;
reg x_reg, x_trig, updn;
output reg [2:0] state;

always @(negedge rst or posedge clk) begin
     if(!rst) begin
          {x_reg, x_trig} <= 2'b00;
     end
     else begin
           x_reg <= x;
           x_trig <= x & ~x_reg;
    end
end

always @(negedge rst or posedge clk) begin
      if(!rst) {state, updn} <= 4'b0001;
     
     else begin
        case(state)
            3'b000 : {state, updn} <= updn ? ( x_trig ? 4'b0011 : 4'b0001) : ( x_trig ? 4'b0011 : 4'b0001);
            3'b001 : {state, updn} <= updn ? ( x_trig ? 4'b0101 : 4'b0011) : ( x_trig ? 4'b0000 : 4'b0010);
            3'b010 : {state, updn} <= updn ? ( x_trig ? 4'b0111 : 4'b0101) : ( x_trig ? 4'b0010 : 4'b0100);
            3'b011 : {state, updn} <= updn ? ( x_trig ? 4'b1001 : 4'b0111) : ( x_trig ? 4'b0100 : 4'b0110);
            3'b100 : {state, updn} <= updn ? ( x_trig ? 4'b1011 : 4'b1001) : ( x_trig ? 4'b0110 : 4'b1000);
            3'b101 : {state, updn} <= updn ? ( x_trig ? 4'b1101 : 4'b1011) : ( x_trig ? 4'b1000 : 4'b1010);
            3'b110 : {state, updn} <= updn ? ( x_trig ? 4'b1111 : 4'b1101) : ( x_trig ? 4'b1010 : 4'b1100);
            3'b111 : {state, updn} <= updn ? ( x_trig ? 4'b1100 : 4'b1110) : ( x_trig ? 4'b1100 : 4'b1110);
            
            
       endcase
   end
end

endmodule

