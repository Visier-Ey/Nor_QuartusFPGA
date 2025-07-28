module breath_led (
    input sys_clk,
    input sys_rst_n,
    output reg [3:0] led,
    input wire count_down
);
    reg [31:0] pwm_max = 32'd100;  // 初始值
    reg [31:0] pwm;
    reg [31:0] cnt;
    reg dir;

    // 主逻辑（合并 pwm 和 cnt 的控制）
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            pwm <= 32'd0;
            cnt <= 32'd0;
            dir <= 1'b1;
        end
        else begin
            // cnt 递增逻辑
            if (cnt < pwm_max) cnt <= cnt + 1;
            else cnt <= 0;

            if (count_down) begin
                if (dir) pwm <= pwm + 1;
                else pwm <= pwm - 1;
                
                if (pwm >= pwm_max) dir <= 1'b0;
                else if (pwm <= 1) dir <= 1'b1;
            end
        end
    end

    // LED 控制逻辑
    always @(posedge sys_clk) begin
        led <= (cnt < pwm) ? 4'b1111 : 4'b0000;
    end
endmodule