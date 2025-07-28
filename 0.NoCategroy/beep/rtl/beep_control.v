module beep_control (
    input wire sys_clk,
    input wire sys_rst_n,
    
    input key_value,
    input key_flag,
    output reg beep
);

    reg [19:0] cnt; // Counter for 1s delay
    reg beep_state; // State of the beep signal

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) 
            beep <= 1'b0;
        else if (key_flag && (~key_value)) beep<=(~beep); 
    end
    
endmodule