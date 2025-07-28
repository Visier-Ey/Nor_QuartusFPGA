module count (
    input sys_clk,
    input sys_rst_n,
    output reg count_down
);
    reg [31:0] cnt;
    reg [31:0] max_cnt;

    //! count toggled each max_cnt
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            max_cnt <= 32'd10_0000_0; // 2ms by 50MHz 
            cnt <= 32'd10_0000_0;
            count_down <= 0;
        end else begin
            if (cnt == 0) begin
                cnt <= max_cnt;  // 重置计数器
                count_down <= 1; // 触发脉冲
            end else begin
                cnt <= cnt - 1;
                count_down <= 0;  // 保持低电平
            end
        end
    end
endmodule