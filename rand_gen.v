module rand_gen(
    input clk,
    input sclk,
    input rst,
    output reg [31:0] rand
    );

    reg [31:0] x;
    reg [31:0] y;
    reg [31:0] z;
    reg [31:0] w;
    reg [31:0] t;

    always @(posedge clk)begin
        if(rst == 1)begin
            x <= 123456789;
            y <= 362426069;
            z <= 521288629;
            w <= 88675123;
            t <= 0;
            rand <= 0;
        end
    end

    always @(posedge sclk)begin
        t <= x^(x<<11);
        x <= y;
        y <= z;
        z <= w;
        w <= (w^(w>>19)) ^ (t^(t>>8));
        rand <= w;
    end

    endmodule