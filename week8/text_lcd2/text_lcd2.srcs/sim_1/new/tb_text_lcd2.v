`timescale 1ns / 1ps
module tb_text_lcd2();

reg rst, clk;
reg [9:0] number_btn;
reg [1:0] control_btn;

wire LCD_E, LCD_RS, LCD_RW;
wire [7:0] LCD_DATA;
wire [7:0] LED_out;

LCD_cursor tb(rst, clk, LCD_E, LCD_RS, LCD_RW, LCD_DATA, LED_out, number_btn, control_btn);

initial begin
    clk <= 0;
    rst <= 1;
    #2 rst <= 0;
    #2 rst <= 1;
    #5 number_btn <= 10'b0000_0000_00;
       control_btn <= 10'b0000_0000_00;
    #30 number_btn <= 10'b0010_0000_00; // 3 
    #30 number_btn <= 10'b0000_0000_10; // 9 
    #5 number_btn <= 10'b0000_0000_00;
    #50 control_btn <= 2'b10; // shift to left
    #50 control_btn <= 2'b01; // shift to right
    end
    
always begin
    #0.5 clk <= ~clk;
end

endmodule