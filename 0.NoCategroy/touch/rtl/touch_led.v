module touch_led (
    input sys_clk,
    input sys_rst_n,

    input touch_key,
    output reg[3:0] led
);

initial begin
    led <= 4'b1111;
end

//! touch and touch the key
always @(posedge touch_key or negedge sys_rst_n) begin
    if (!sys_rst_n) led <= 4'b0000;
    else led <= ~led;
end


endmodule        