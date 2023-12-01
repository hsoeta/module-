`timescale 1ns / 1ps

module ad1_spi(
    input clk_100M,
    input rst,
    input sdin,
    input acq_timing,
    output cs,
    output sclk,
    output reg drdy,
    output reg [15:0] dout,
    output wire [1:0]  led
);

    parameter INCLUDE_DEBUG_INTERFACE     = 1;
    parameter CLOCKS_PER_BIT              = 5;//1 bit per 50ns 16bit * 50 = 800ns
    parameter CLOCKS_BEFORE_DATA          = 5;//50ns
    parameter CLOCKS_AFTER_DATA           = 5;//50ns
    parameter CLOCKS_BETWEEN_TRANSACTIONS = 10;//100ns

    localparam BITS_PER_TRANSACTION       = 16;
    localparam BIT_HALFWAY_CLOCK          = CLOCKS_PER_BIT>>1;

    localparam S_HOLD        = 0; // 100ns
    localparam S_FRONT_PORCH = 1; // 50ns
    localparam S_SHIFTING    = 2; // 16*sclk.per
    localparam S_BACK_PORCH  = 3; // 50ns

    reg [1:0] state   = S_HOLD;
    reg [31:0] count0 = 0;
    reg [31:0] count1 = 0;
    reg [15:0] sreg  = 0;

    assign cs = (state == S_HOLD) ? 1 : 0;
    assign sclk = (state == S_SHIFTING && count0 <= BIT_HALFWAY_CLOCK-1) ? 0 : 1;

    generate if (INCLUDE_DEBUG_INTERFACE == 1)
        assign led = state;
    endgenerate

    always@(posedge clk_100M)
        if (rst == 1) begin
            drdy <= 0;
            dout <= 0;
            state <= S_HOLD;
            count0 <= 0;
            count1 <= 0;
            sreg <= 0;
        end else case (state)
        S_HOLD: if (count0 == CLOCKS_BETWEEN_TRANSACTIONS-1) begin
            state <= S_FRONT_PORCH;
            count0 <= 0;
        end else
            count0 <= count0 + 1;
        S_FRONT_PORCH: if (count0 == CLOCKS_BEFORE_DATA-1) begin
            state <= S_SHIFTING;
            count0 <= 0;
            count1 <= 0;
            sreg <= 0;
        end else
            count0 <= count0 + 1;
        S_SHIFTING: if (count0 == CLOCKS_PER_BIT-1) begin
            count0 <= 0;
            if (count1 == BITS_PER_TRANSACTION-1) begin
                dout <= sreg;
                drdy <= 1;
                state <= S_BACK_PORCH;
            end else
                count1 <= count1 + 1;
        end else begin
            count0 <= count0 + 1;
            if (count0 == BIT_HALFWAY_CLOCK-1) begin
                sreg <= {sreg[14:0], sdin};
            end
        end
        S_BACK_PORCH: if (count0 == CLOCKS_AFTER_DATA-1) begin
            count0 <= 0;
            drdy <= 0;
            state <= S_HOLD;
        end else
            count0 <= count0 + 1;
        endcase
        
endmodule