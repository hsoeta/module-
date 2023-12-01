`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/03 14:34:52
// Design Name: 
// Module Name: Sensor_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Sensor_ctrl(
    input OSC,
    input sys_reset,
    
    output rst,
    output clk_1M,
    output clk_100M,
    output clk_125M,
    output gain,
    output clk_1M_inverse,
    output rst_inverse,
    output gain_inverse,
    output led0_b,
    output led1_g
    );
    
    assign led0_b = 1'b1;
    assign led1_g = 1'b1;
    parameter [19:0] srate = 20'd100000; //Need more than 1050
    
//////////clocking wizard//////////
    wire clk_100M;
    //wire sys_reset;
    reg  clk_reset = 0;
    
    clk_wiz_0 U1(
        .clk_out1   (clk_100M),
        .clk_out2   (clk_125M),
        .reset      (clk_reset),
        //.locked     (sys_reset),
        .clk_in1    (OSC)
        );
        
//////////generating clk_1M//////////
    reg clk_1M;
    reg [6:0]  counter_clk100M;
    
    initial begin
        clk_1M          = 0;
        counter_clk100M = 0;
    end
    always@(posedge clk_100M)begin
        if(counter_clk100M == 7'd49)begin
            clk_1M          <= 1'b1;
            counter_clk100M <= counter_clk100M + 1;
        end else
        if(counter_clk100M == 7'd99)begin  
            clk_1M          <= 1'b0;
            counter_clk100M <= 0;
        end else begin
            counter_clk100M <= counter_clk100M +1;
        end
    end
    
//////////counter_clk1M//////////
    reg [19:0] counter_clk1M;
    
    initial begin
        counter_clk1M = 0;
    end
    always@(posedge clk_1M) begin
        if(counter_clk1M == srate)begin
            counter_clk1M <= 1;
        end else begin
            counter_clk1M <= counter_clk1M + 1;
        end
    end
    
//////////generating rst//////////
    reg rst;
    
    initial begin
        rst = 1'b1;
    end
    always@(posedge clk_1M)begin
        if(counter_clk1M == 0)begin
            rst <= 1'b0;
        end else
        if(counter_clk1M == 21)begin
            rst <= 1'b1;
        end else
        if(counter_clk1M == srate)begin
            rst <= 1'b0;
        end else begin
            rst <= rst;
        end
    end

    
//////////generating gain//////////
    reg gain;
    
    initial begin
        gain = 1'b1;
    end
    
//////////Pmod assignment//////////
assign clk_1M_inverse = ~(clk_1M);
assign rst_inverse    = ~rst;
assign gain_inverse   = ~gain;

        
    
       
                 
endmodule

