`timescale 1ns / 1ps
module tbforjkflipflop();  
reg j, k, clk;  
wire q;

jkflipflop tb ( 
.j(j),  
.k(k),  
.clk(clk),  
.q(q)
);  
  
   initial begin
   clk <= 0;  
j <= 0;  
k <= 0;   
#20 
j <= 0;  
k <= 1;  
#20 
j <= 0;  
k <= 0;  
#20 
j <= 1;  
k <= 0;
#20 
j <= 0;  
k <= 0;
#20 
j <= 1;  
k <= 1;
#20 
j <= 0;  
k <= 0;  
end

always begin
#5 clk <= ~clk;
end   

endmodule  