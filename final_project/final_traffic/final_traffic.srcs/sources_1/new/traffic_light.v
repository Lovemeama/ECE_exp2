`timescale 1ns / 1ps
module traffic_light(clk, rst, S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                     S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                     S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT,
                     LCD_E, LCD_RS, LCD_RW, LCD_DATA, LED_out, mag_10, mag_100, mag_200,
                     btn_plushour, btn_emg);
                     
input clk, rst;
input mag_10, mag_100, mag_200; // for magnifying time // U2, T1, W4 in row (DIP 3 4 5)

input btn_plushour; //for +1 hour allocate K4, SM_1 
input btn_emg; // for emergency case allocate N4, SM_3
reg btn_plushour_reg, btn_emg_reg; 
reg btn_plushour_trig, btn_emg_trig;  // for oneshot trigger for each button
reg emg = 0; // this is delclared for emergency case 

// for traffic light//
output reg S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, 
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,         
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,        
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,     
           S_RED, N_RED, W_RED, E_RED,                 
           S_LEFT, N_LEFT, W_LEFT, E_LEFT;

reg [4:0] reg_state; // for stating state in text LCD. this is for register calculation
reg [4:0] prst_state; // for saving present state. used when btn_emg on
reg [4:0] state; // to make it easy for case statements and for coding
parameter A     = 5'b00000,
          ATOD  = 5'b00001,
         D     = 5'b00010,
         DTOF  = 5'b00011,
         F     = 5'b00100,
         FTOE1 = 5'b00101,
         E1    = 5'b00110,
         E1TOG = 5'b00111,
         G     = 5'b01000,
         GTOE2 = 5'b01001,
         E2    = 5'b01010,
         E2TOA = 5'b01011,
         B     = 5'b01100,
         BTOA1 = 5'b01101,
         A1    = 5'b01110,
         A1TOC = 5'b01111,
         C     = 5'b10000,
         CTOA2 = 5'b10001,
         A2    = 5'b10010,
         A2TOE3= 5'b10011,
         E3    = 5'b10100,
         E3TOH = 5'b10101,
         H     = 5'b10110,
         HTOB  = 5'b10111;
//               //
// for lcd watch //
output LCD_E, LCD_RS, LCD_RW;
output reg [7:0] LCD_DATA;
output reg [7:0] LED_out;
wire LCD_E;
reg LCD_RS, LCD_RW;
reg DAY;
reg [7:0] sec_1, sec_10, min_1, min_10, hour_1, hour_10;
reg [2:0] LCD_state;
parameter DELAY = 3'b000,
          FUNCTION_SET = 3'b001,
          ENTRY_MODE = 3'b010,
          DISP_ONOFF = 3'b011,
          LINE1 = 3'b100,
          LINE2 = 3'b101,
          DELAY_T = 3'b110,
          CLEAR_DISP = 3'b111;

integer cnt; // for traffic light
integer ive; // for digital clock
integer gpt; // for LCD

always @(posedge clk or negedge rst) begin // for oneshot trig of plushour button
    if(!rst) begin
        btn_plushour_reg <= 0;
        btn_plushour_trig <= 0;
    end
    else begin
        btn_plushour_reg <= btn_plushour;
        btn_plushour_trig <= btn_plushour & ~btn_plushour_reg;
    end
end

always @(posedge clk or negedge rst) begin // for oneshot trig of emeergency button
    if(!rst) begin
        btn_emg_reg <= 0;
        btn_emg_trig <= 0;
    end
    else begin
        btn_emg_reg <= btn_emg;
        btn_emg_trig <= btn_emg & ~btn_emg_reg;
    end
end


always @(posedge clk or negedge rst) begin
   if(!rst) begin
      sec_1 <= 0; 
      sec_10 <= 0; 
      min_1 <= 0; 
      min_10 <= 0; 
      hour_1 <= 0; 
      hour_10 <= 0;
   end
   else begin
     if(mag_10) begin
             if(ive >= 90) begin
            sec_1 = sec_1 + 1;
            ive = 0;
        end
        else begin
            ive = ive + 10;
        end
     end                        
     else if(mag_100)          
            sec_1 = sec_1 + 1;
     else if(mag_200)          
            sec_1 = sec_1 + 2;
     else begin
        if(ive >= 99) begin   
            sec_1 = sec_1 + 1;
            ive = 0;
        end
        else begin
            ive = ive + 1;
        end
     end  
      if(btn_plushour_trig) begin
        if((hour_10 != 2) && (hour_1 == 9)) begin
            hour_10 = hour_10 + 1;
            hour_1 = 0;
        end
        else if((hour_10 == 2) && (hour_1 >= 3)) begin
            hour_10 = 0;
            hour_1 = 0;
        end
        else hour_1 = hour_1 + 1;
      end
      else begin
      if(sec_1 >= 10) begin
         sec_10 = sec_10 + 1;
         sec_1 = 0;
      end
      if(sec_10 == 6) begin
         min_1 = min_1 + 1;
         sec_10 = 0;
      if(min_1 == 10) begin
         min_10  = min_10 + 1;
         min_1 = 0;
      end
      if(min_10 == 6) begin
         hour_1 = hour_1 + 1;
         min_10 = 0;
      end
        if((hour_10 == 3) || (hour_10 == 2) && ((hour_1 >= 4) && (hour_1 <10))) begin // 23:59 after 1 minute becomes 00:00
            hour_1 = 0;
            hour_10 = 0;
        end
        else if (hour_1 == 10) begin
            hour_10 = hour_10 + 1;
            hour_1 = 0;
        end
   end
end
end
end      
      
always @(posedge clk or negedge rst) begin
   if(!rst) begin
   DAY <= 0;
   end
   else begin
      if((hour_10 == 0 && hour_1 >= 8) || (hour_10 == 1 && hour_1 <= 9) || (hour_10 == 2 && hour_1 <= 2)) // in 0800 ~ 2259 'DAY' is assigned 1 
      DAY <= 1;
      else
      DAY <= 0; // the other time 'DAY' is assigned 0, and we use this as 'NIGHT' rather declaring variable NIGHT
   end
end
                     
always @(posedge clk or negedge rst) begin // state changing statement
    if(!rst) begin
        state <= A;
        cnt <= 0;
    end
    else if(btn_emg_trig || emg) begin
        state <= (cnt >= 1600) ? prst_state : ((cnt >= 100 && emg == 1) ? A : prst_state);
 // (explanation for above statements) if cnt is over 1600, 'state' becomes 'prst_state'. else check if cnt is over 100 and emg is assigned 1 //
 // if those 2 conditions are satisfied, 'state' becomes A else 'state' becomes 'prst_state' //
    if(cnt >= 1600) cnt <= 0;
      else if(!emg)
         cnt <= 0;
         else if(emg) begin // these are for time magnifying at emergency state
            cnt <= cnt + 1;
            end
            emg <= (cnt >= 1600) ? 0 : 1; // assign emg 0 or 1 depending on cnt
            end 
            else begin prst_state <= state; // if btn_emg_trig is not put in, nothing happens
        if(DAY) begin
            case(state)
                A : if(cnt >= 500) begin
                  state <= ATOD;
                  cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1; 
                ATOD : if(cnt >= 100) begin // we hold lasting time of yellow sign for a sec. no matter DAY or ~DAY (NIGHT)
                   state <= D;
                   cnt <= 0;
                   end
                   
                    else cnt <= cnt + 1;
                D : if(cnt >= 500) begin
                   state <= DTOF;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;
                    
                DTOF : if(cnt >= 100) begin
                   state <= F;
                   cnt <= 0;
                   end
                  
                   else cnt <= cnt + 1;
                F : if(cnt >= 500) begin
                    state <= FTOE1;
                    cnt <= 0;
                    end 
                   
                    else cnt <= cnt + 1;
                    
                FTOE1 : if(cnt >= 100) begin 
                   state <= E1;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;
                E1 : if(cnt >= 500) begin 
                   state <= E1TOG;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;
                E1TOG : if(cnt >= 100) begin
                   state <= G;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;
                G : if(cnt >= 500) begin
                   state <= GTOE2;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;
                GTOE2 : if(cnt >= 100) begin 
                   state <= E2;
                   cnt <= 0;
                   end
                  
                   else cnt <= cnt + 1;
                E2 : if(cnt >= 500) begin
                   state <= E2TOA;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;                    
                E2TOA : if(cnt >= 100) begin
                   state <= A;
                   end
                  
                   else cnt <= cnt + 1;
                default : begin
                  state <= A;
                  
                  end
                  endcase
                  end
        else if(!DAY) begin
            case(state)
                B : if(cnt >= 1000) begin
                   state <= BTOA1;
                   cnt <= 0;
                   end 
                  
                   else cnt <= cnt + 1;
                BTOA1 : if(cnt >= 200) begin
                   state <= A1;
                   cnt <= 0;
                   end 
                  
                   else cnt <= cnt + 1;
                A1 : if(cnt >= 1000) begin
                   state <= A1TOC;
                   cnt <= 0;
                   end
                  
                   else cnt <= cnt + 1;
                A1TOC : if(cnt >= 200) begin
                   state <= C;
                   cnt <= 0;
                   end 
                  
                   else cnt <= cnt + 1;                         
                C : if(cnt >= 1000) begin
                   state <= CTOA2;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;                    
                CTOA2 : if(cnt >= 200) begin
                   state <= A2;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;
                A2 : if(cnt >= 1000) begin
                   state <= A2TOE3;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;                   
                A2TOE3 : if(cnt >= 200) begin
                   state <= E3;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;                         
                E3 : if(cnt >= 1000) begin
                   state <= E3TOH;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;
                E3TOH : if(cnt >= 200) begin
                   state <= H;
                   cnt <= 0;
                   end
                   
                   else cnt <= cnt + 1;
                H : if(cnt >= 1000) begin
                   state <= HTOB;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;
                HTOB : if(cnt >= 200) begin
                   state <= B;
                   cnt <= 0;
                   end 
                   
                   else cnt <= cnt + 1;                      
                default : begin
                   state <= B;
                   
                   end        
            endcase
        end
    end
end           


always @(posedge clk or negedge rst) begin // made every case for flash on/off of pedestrian signal for i didn't know how to make them blink with short codes
    if(!rst)
        {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
        S_W_RED, N_W_RED, W_W_RED, E_W_RED,
        S_GREEN, N_GREEN, W_GREEN, E_GREEN,
        S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
        S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT}
        = 24'b0011_1100_1100_0000_0011_0000; // A
      else begin
        case(state)
            A : if(cnt <= 250)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0011_1100_1100_0000_0011_0000;
                else if(cnt <= 300)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1100_1100_0000_0011_0000; // flash off
                else if(cnt <= 350)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0011_1100_1100_0000_0011_0000; //flash on
                else if(cnt <= 400)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1100_1100_0000_0011_0000; // repeat flash
                else if(cnt <= 450)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0011_1100_1100_0000_0011_0000;
                else if(cnt <= 490) // this is for emg state. lasting light
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1100_1100_0000_0011_0000;
                else if(cnt <= 500)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0011_1100_1100_0000_0011_0000;
           ATOD : if(cnt <= 100)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
               S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_1100_0011_0000;                
           D : if(cnt <= 500)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_0000_0011_1100;  //no flash              
           DTOF : if(cnt <= 100)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
               S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_1100_0011_0000;
           F : if(cnt <= 500)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0100_1011_0010_0000_1101_0010; //no flash
           FTOE1 : if(cnt <= 100)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
               S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_0010_1101_0010;
           E1 : if(cnt <= 250)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1100_0011_0011_0000_1100_0000;
                else if(cnt <= 300)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0011_0011_0000_1100_0000; //flash off
                else if(cnt <= 350)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1100_0011_0011_0000_1100_0000; //flash on
                else if(cnt <= 400)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT,
                N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0011_0011_0000_1100_0000; // repeat flash
                else if(cnt <= 450)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1100_0011_0011_0000_1100_0000;
                else if(cnt <= 500)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0011_0011_0000_1100_0000;                
           E1TOG : if(cnt <= 100)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
               S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_0011_1100_0000;
           G : if(cnt <= 250)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1000_0111_0001_0000_1110_0001;
                else if(cnt <= 300)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0111_0001_0000_1110_0001; //flash off
                else if(cnt <= 350)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1000_0111_0001_0000_1110_0001; //flash on
                else if(cnt <= 400)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0111_0001_0000_1110_0001;
                else if(cnt <= 450)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1000_0111_0001_0000_1110_0001;
                else if(cnt <= 500)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0111_0001_0000_1110_0001;
           GTOE2 : if(cnt <= 100)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
               S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_0001_1110_0000;
           E2 : if(cnt <= 250)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1100_0011_0011_0000_1100_0000;
                else if(cnt <= 300)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0011_0011_0000_1100_0000; //flash off
                else if(cnt <= 350)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1100_0011_0011_0000_1100_0000; //flash on
                else if(cnt <= 400)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0011_0011_0000_1100_0000;
                else if(cnt <= 450)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b1100_0011_0011_0000_1100_0000;
                else if(cnt <= 500)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
                S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_0011_0011_0000_1100_0000;
           E2TOA : if(cnt <= 100)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
               S_W_RED, N_W_RED, W_W_RED, E_W_RED,
                S_GREEN, N_GREEN, W_GREEN, E_GREEN,
                S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED,
                S_LEFT, N_LEFT, W_LEFT, E_LEFT}
                = 24'b0000_1111_0000_0011_1100_0000;

                        /////////////NIGHT //////////
       B : if(cnt <= 500)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0001_1110_0100_0000_1011_0100;
           else if(cnt <= 600)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1110_0100_0000_1011_0100;
           else if(cnt <= 700)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0001_1110_0100_0000_1011_0100;
           else if(cnt <= 800)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1110_0100_0000_1011_0100;
           else if(cnt <= 900)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0001_1110_0100_0000_1011_0100;
           else if(cnt <= 1000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1110_0100_0000_1011_0100;
       BTOA1 : if(cnt <= 100)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1111_0000_0100_1011_0000;
       A1 : if(cnt <= 500)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 600)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1100_1100_0000_0011_0000;
           else if(cnt <= 700)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 800)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1100_1100_0000_0011_0000;
           else if(cnt <= 900)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 1000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1100_1100_0000_0011_0000;
       A1TOC : if(cnt <= 100)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1111_0000_1100_0011_0000;
       C : if(cnt <= 500)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0010_1101_1000_0000_0111_1000;
          else if(cnt <= 600)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0000_1101_1000_0000_0111_1000;
          else if(cnt <= 700)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0010_1101_1000_0000_0111_1000;
          else if(cnt <= 800)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0000_1101_1000_0000_0111_1000;
          else if(cnt <= 900)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0010_1101_1000_0000_0111_1000;
          else if(cnt <= 1000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
           S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0000_1101_1000_0000_0111_1000;
      CTOA2 : if(cnt <= 1000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
          S_GREEN, N_GREEN, W_GREEN, E_GREEN,
          S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED,
          S_LEFT, N_LEFT, W_LEFT, E_LEFT}
          = 24'b0000_1111_0000_1000_0111_0000;
      A2 : if(cnt <= 500)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 600)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1100_1100_0000_0011_0000;
           else if(cnt <= 700)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 800)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1100_1100_0000_0011_0000;
           else if(cnt <= 900)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 1000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1100_1100_0000_0011_0000;
       A2TOE3 : if(cnt <= 100)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1111_0000_1100_0011_0000;
       E3 : if(cnt <= 500)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b1100_0011_0011_0000_1100_0000;
           else if(cnt <= 600)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_0011_0011_0000_1100_0000;
           else if(cnt <= 700)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b1100_0011_0011_0000_1100_0000;
           else if(cnt <= 800)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_0011_0011_0000_1100_0000;
           else if(cnt <= 900)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b1100_0011_0011_0000_1100_0000;
           else if(cnt <= 1000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_0011_0011_0000_1100_0000;
       E3TOH : if(cnt <= 100)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1111_0000_0011_1100_0000;
       H : if(cnt <= 1000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN,
          S_W_RED, N_W_RED, W_W_RED, E_W_RED,
           S_GREEN, N_GREEN, W_GREEN, E_GREEN,
           S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED,
           S_LEFT, N_LEFT, W_LEFT, E_LEFT}
           = 24'b0000_1111_0000_0000_1100_0011;
       endcase
   end
end

//LCD CLOCK BEGIN //

always @(posedge clk or negedge rst) begin // to write present state in text lcd line2
   if(!rst) reg_state <= 5'b00000;
   else begin
      case(state)
         A, A1, A2: reg_state <= 5'b00001; // to plus reg_state for writing what is present state on LINE2
         B: reg_state <= 5'b00010;
         C: reg_state <= 5'b00011;
         D: reg_state <= 5'b00100;
         E1, E2, E3: reg_state <= 5'b00101;
         F: reg_state <= 5'b00110;
         G: reg_state <= 5'b00111;
         H: reg_state <= 5'b01000;
         default: reg_state <= reg_state; // No change for other states
      endcase
   end
end
   
always @(posedge clk or negedge rst) begin // actually copied it from week 9 (text_lcd)
   if(!rst) LCD_state = DELAY;
   else begin
      case(LCD_state)
        DELAY : begin
            LED_out = 8'b1000_0000;
            if(gpt == 70) LCD_state = FUNCTION_SET;
        end
        FUNCTION_SET : begin
            LED_out = 8'b0100_0000;
            if(gpt == 10) LCD_state = DISP_ONOFF;
        end
        DISP_ONOFF : begin
           LED_out = 8'b0010_0000;
           if(gpt == 10) LCD_state = ENTRY_MODE;
        end
           ENTRY_MODE : begin
           LED_out = 8'b0001_0000;
        if(gpt == 10) LCD_state = LINE1;
        end
           LINE1 : begin
           LED_out = 8'b0000_1000;
        if(gpt == 30) LCD_state = LINE2;
        end
           LINE2 : begin
           LED_out = 8'b0000_0100;
        if(gpt == 30) LCD_state = DELAY_T;
        end
           DELAY_T : begin
           LED_out = 8'b0000_0010;
        if(gpt == 35) LCD_state = CLEAR_DISP;
        end
        CLEAR_DISP : begin
           LED_out = 8'b0000_0001;
           if(gpt == 5) LCD_state = LINE1;
        end
        default : LCD_state = DELAY;
        endcase
   end
end

always @(posedge clk or negedge rst)
   begin
      if(!rst) gpt = 0;
   else begin
      case(LCD_state)
         DELAY :
            if(gpt >= 70) gpt = 0;
            else gpt = gpt + 1;
         FUNCTION_SET :
            if(gpt>= 10) gpt = 0;
            else gpt = gpt + 1;
         DISP_ONOFF :
            if(gpt >= 10) gpt = 0;
            else gpt = gpt + 1;
         ENTRY_MODE :
            if(gpt >= 10) gpt = 0;
            else gpt = gpt + 1;
         LINE1 :
            if(gpt >= 30) gpt = 0;
            else gpt = gpt + 1;
         LINE2 :
            if(gpt >= 30) gpt = 0;
            else gpt = gpt + 1;
         DELAY_T :
            if(gpt >= 35) gpt = 0;
            else gpt = gpt + 1;
         CLEAR_DISP :
            if(gpt >= 5) gpt = 0;
            else gpt = gpt + 1;
         default : LCD_state = DELAY;
      endcase
   end
end



always @(posedge clk or negedge rst) begin
   if(!rst)
      {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_1_0000_0000;
   else begin
      case(LCD_state)
         FUNCTION_SET :
            {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0011_1000;
         DISP_ONOFF :
            {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_1100;
         ENTRY_MODE :
            {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_0110;   
LINE1 : 
   begin
      case(gpt)
         00 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_1000_0000;
         01 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0101_0100; // T
         02 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_1001; // i
         03 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_1101; // m
         04 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0101; // e
         05 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         06 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0011_1010; // :
         07 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         08 : begin                                          // hour_10 
         {LCD_RS, LCD_RW} = 2'b10; 
         LCD_DATA = 8'b0011_0000 + hour_10;                   
         end
         09 : begin                                          // hour_1
         {LCD_RS, LCD_RW} = 2'b10; 
         LCD_DATA = 8'b0011_0000 + hour_1; 
         end
         10 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0011_1010; // :
         11 : begin                                          // min_10
         {LCD_RS, LCD_RW} = 2'b10; 
         LCD_DATA = 8'b0011_0000 + min_10; 
         end
         12 : begin                                          // min_1
         {LCD_RS, LCD_RW} = 2'b10; 
         LCD_DATA = 8'b0011_0000 + min_1; 
         end
         13 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0011_1010; // :
         14 : begin                                          // sec_10
         {LCD_RS, LCD_RW} = 2'b10; 
         LCD_DATA = 8'b0011_0000 + sec_10; 
         end
         15 : begin                                          // sec_1
         {LCD_RS, LCD_RW} = 2'b10; 
         LCD_DATA = 8'b0011_0000 + sec_1; 
         end
         16 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
         default : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
      endcase
   end
LINE2 : 
   begin
    if(!DAY) begin // NIGHT
      case(gpt)
         00 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_1100_0000;
         01 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0101_0011; // S
         02 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0111_0100; // t
         03 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0001; // a
         04 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0111_0100; // t
         05 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0101; // e
         06 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         07 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0011_1010; // :
         08 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         09 : begin
         {LCD_RS, LCD_RW} = 2'b10;
         LCD_DATA = 8'b0100_0000 + reg_state;
         end // which state in parameter
         10 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_1000; // ( if night
         11 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_1110; // n
         12 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_1001; // i
         13 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0111; // g
         14 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_1000; // h
         15 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0111_0100; // t
         16 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_1001; // )
         default : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
      endcase
   end
   else begin // DAY
        case(gpt)
         00 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_1100_0000;
         01 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0101_0011; // S
         02 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0111_0100; // t
         03 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0001; // a
         04 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0111_0100; // t
         05 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0101; // e
         06 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         07 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0011_1010; // :
         08 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         09 : begin
         {LCD_RS, LCD_RW} = 2'b10;
         LCD_DATA = 8'b0100_0000 + reg_state;
         end // which state in parameter
         10 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_1000; // ( if day
         11 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0100; // d
         12 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0110_0001; // a
         13 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0111_1001; // y
         14 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_1001; // )
         15 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         16 : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; // blank
         default : {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_0_0010_0000; //
      endcase
   end
end
      DELAY_T :
         {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_0010;
      CLEAR_DISP :
         {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_0001;
      default :
         {LCD_RS, LCD_RW, LCD_DATA} = 10'b1_1_0000_0000;
   endcase
 end
end

assign LCD_E = clk;        
endmodule