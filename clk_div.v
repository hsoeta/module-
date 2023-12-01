`timescale 1ns / 1ps

module clk_div(
    input clk_100M,
    output clk_80M,
    output clk_20M,
    output reg clk_4M,
    input clk_wiz_reset,
    output locked
    );
    
  reg [3:0] count = 0;
  parameter DEVIDE_VALUE = 4'd9; // 80MHzクロックを20分周して4MHzクロックを生成する

//clocking_wizard のインスタンス化
  clk_wiz_0 U1(
    .clk_out1 (clk_80M), // output clk_out1 = 80MHz 
    .clk_out2 (clk_20M), // output clk_out2 = 20MHz
    .reset    (clk_wiz_reset),       // input reset
    .locked   (locked),              // output locked
    .clk_in1  (clk_100M)  // input clk_in1   = 100MHz
    ); 

initial begin
  clk_4M = 0;
  count = 0;
end

  //クロック分周ロジック
  always @(posedge clk_80M)begin
    if(locked)begin
      if(count == DEVIDE_VALUE)begin
        count <= 0;
        clk_4M = ~clk_4M;
      end else begin
        count <= count + 1;
      end
    end
  end

endmodule
