`timescale 1ns / 1ps
module seg_counter(clk, rst, btn, seg);

input clk, rst;
input btn;
wire btn_trig;
reg [3:0] state;
output reg [7:0] seg;

oneshot #(.WIDTH(10)) o1(clk, rst, btn, btn_trig);

always @(negedge rst or posedge clk) begin
  if(!rst) seg <= 8'b00000000;
  else begin
    case (state)
       0 : seg <= 8'b11111100;
       1 : seg <= 8'b01100000;
       2 : seg <= 8'b11011010;
       3 : seg <= 8'b11110010;
       4 : seg <= 8'b01100110;
       5 : seg <= 8'b10110110;
       6 : seg <= 8'b10111110;
       7 : seg <= 8'b11100000;
       8 : seg <= 8'b11111110;
       9 : seg <= 8'b11110110;
       default : seg <= 8'b00000000;
    endcase
  end
end

always @(negedge rst or posedge clk) begin
   if(!rst) state <= 4'b0000;
   else if(state == 4'b1001 && btn_trig == 1) state <= 4'b0000;
   else if(btn_trig == 1) state <= state + 1;
 end       
endmodule
