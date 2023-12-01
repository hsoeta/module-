`timescale 1ns / 1ps

module sensor_ctrl(
    input clk_100M,
    input clk_4M,
    input sys_rst,
    output reg sen_rst,
    output reg acq_timing,
    output reg [10:0] count,
    output reg [8:0]  data_count,
    output reg [31:0] cycle_count
);

    parameter SENSOR_CYCLE             = 11'd1041; //センサ1サイクル時間. 4CLK/1ch * 256ch = 1042CLK
    parameter SENSOR_RESET_PULSE_WIDTH = 11'd20;   //センサリセットパルス幅. 21CLK minimun.
    parameter SENSOR_QUIET_TIME        = 11'd17;   //センサ沈黙時間. リセットパルス立ち下がりエッジから18CLK後に1ch目のデータが出現.
    parameter SENSOR_CHANNELS          = 9'd256;   //センサチャンネル数.　合計256ch.

    initial begin
        sen_rst = 1'b1;
        count   = 11'b0;
        acq_timing = 1'b0;
        data_count = 9'b0;
        cycle_count = 32'b0;
    end

    ///////////////////////
    /*   全体リセット処理   */
    ///////////////////////

    //sys_rst が有効な間はセンサ停止
    //sys_rst 解除後にセンサ始動

    always @(posedge clk_4M)begin
        if(sys_rst == 1'b1)begin
            sen_rst    <= 1'b1;
            acq_timing <= 1'b0;
        end
    end

    always @(negedge sys_rst)begin
        sen_rst <= 1'b0;
    end

    ////////////////////////////
    /*   sen_rst 生成ロジック   */
    ////////////////////////////

    always @(posedge clk_4M)begin
        if(count == SENSOR_CYCLE)begin
            sen_rst <= 1'b0;
            count   <= 0;
        end else if(count == SENSOR_RESET_PULSE_WIDTH)begin
            sen_rst <= 1'b1;
            count   <= count + 1'b1;
        end else begin
            count <= count + 1'b1;
        end
    end

    ///////////////////////////////
    /*   acq_timing 関連ロジック   */
    ///////////////////////////////

    //count = 19,23,27 ... 1039 の時に立てたい (4n+3 かつ count > 18)
    always @(posedge clk_4M)begin
        if(count <= SENSOR_QUIET_TIME || (count % 4) != 2)begin
            acq_timing <= 1'b0;
        end else begin
            acq_timing <= 1'b1;
        end
    end

    //acq_timing のタイミングでインクリメントするカウンタ. 確認などに用いた.
    always @(posedge acq_timing)begin
        if(data_count == SENSOR_CHANNELS)begin
            data_count <= 9'd1;
        end else begin
            data_count <= data_count + 1;
        end
    end

    //sen_rst　の立ち下がり回数 (=センササイクル数) のカウンタ. 
    always @(negedge sen_rst)begin
        cycle_count <= cycle_count + 1;
    end


endmodule

    