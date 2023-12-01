module top_module(
    input wire clk_100M,
    input wire reset,
    input wire sdin,

    output wire sen_rst,
    output wire cs,
    output wire sclk,
    output wire [9:0] wr_data_count,
    output wire [9:0] rd_data_count,
    output wire [1:0] led
);

  clk_div clk_div_inst (
    .clk_100M(clk_100M),
    .clk_20M(clk_20M),
    .clk_4M(),
    .clk_wiz_reset(),
    .locked()
  );

  sensor_ctrl sensor_ctrl_inst (
    .clk_100M(clk_100M),
    .clk_4M(clk_div_inst.clk_4M),
    .sys_rst(reset),
    .sen_rst(sen_rst),
    .acq_timing(),
    .count(),
    .data_count(),
    .cycle_count()
  );

  ad1_spi ad1_spi_inst (
    .clk_100M(clk_100M),
    .rst(reset),
    .sdin(sdin),
    .acq_timing(sensor_ctrl_inst.acq_timing),
    .cs(cs),
    .sclk(sclk),
    .drdy(drdy),
    .dout(),
    .led(led)
  );

  fifo_generator_0 fifo_inst (
    .rst(),
    .wr_clk(clk_div_inst.clk_20M),
    .rd_clk(clk_100M),
    .din(ad1_spi_inst.dout),
    .wr_en(wr_en),
    .rd_en(),
    .dout(),
    .full(),
    .almost_full(),
    .empty(),
    .almost_empty(),
    .wr_data_count(wr_data_count),
    .rd_data_count(rd_data_count)
    );

    reg wr_en;
    wire clk_20M;
    wire drdy;

    //FIFO wr_en ロジック
    //drdy の立ち上がりをトリガーに、wr_en の時間幅をclk_20MHzと合わせる
    always@(posedge clk_20M)begin
        if(drdy == 1)begin
            wr_en <= 1;
        end else if (wr_en == 1)begin
            wr_en <= 0;
        end
    end


    endmodule