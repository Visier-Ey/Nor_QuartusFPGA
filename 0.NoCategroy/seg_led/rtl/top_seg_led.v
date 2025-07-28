module top_seg_led (
    input sys_clk,
    input sys_rst_n,

    output [7:0] seg_led,
    output [5:0] seg_sel
);

    wire count_down;

    i_seg_led u_seg_led (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .count_down(count_down),
        .seg_led(seg_led),
        .seg_sel(seg_sel)
    );

    count u_count (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .count_down(count_down)
    );
    
endmodule