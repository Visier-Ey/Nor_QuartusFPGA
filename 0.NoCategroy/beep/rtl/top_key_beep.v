module top_key_beep (
    input sys_clk,
    input sys_rst_n,
    input key,
    output beep
);

wire key_value; // Buffered key value
wire key_flag; // Key value flag

key_debounce key_debounce_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .key(key),
    .key_value(key_value),
    .key_flag(key_flag)
);
beep_control beep_control_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .key_value(key_value),
    .key_flag(key_flag),
    .beep(beep)
);
    
endmodule