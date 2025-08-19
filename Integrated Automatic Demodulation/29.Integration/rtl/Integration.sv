module Integration (
    input wire sys_clk,       // 50MHz系统时钟
    input wire sys_rst_n,         
    
    input wire [7:0] d_in,   
    input wire [1:0] mode_select, // 模式选择: 00-AM, 01-BPSK, 10-FM, 11-保留
    output wire [15:0] d_out, 
    // 状态指示
    output wire [2:0] status_led
);

    wire clk_100m, clk_30m, clk_400m;  
    wire rst;
    wire pll_locked;                   
    assign rst = sys_rst_n & pll_locked; // 复位信号

    wire [7:0] am_out;
    wire signed [7:0] bpsk_out;
    wire signed [15:0] fm_out;
    

    reg [15:0] selected_data;

    wire SysClk = clk_100m;
    
    // PLL实例化
    pll pll_inst (
        .areset(~sys_rst_n),
        .inclk0(sys_clk),
        .c0(clk_100m),      // 100MHz
        .c1(clk_30m),      // 30MHz
        .c2(clk_400m),      // 400MHz
        .locked(pll_locked)
    );
    
    // AM解调模块实例化
    AM_ASK am_demod (
        .clk(SysClk),
        .rst_n(rst),
        .d_in(d_in),
        .d_out(am_out)
    );
    
    // BPSK解调模块实例化
    BPSK bpsk_demod (
        .clk(SysClk),
        .rst_n(rst),
        .d_in(d_in),
        .d_out(bpsk_out)
    );
    
    // FM解调模块实例化
    FM fm_demod (
        .clk(SysClk),
        .rst_n(rst),
        .d_in(d_in),
        .phi_inc(32'd42_949_673),
        .d_out(fm_out)
    );
    
    // 数据选择逻辑
    always @(*) begin
        case (mode_select)
            2'b00: begin  // AM/ASK模式
                selected_data = {8'h00, am_out};
            end
            2'b01: begin  // BPSK模式
                selected_data = {8'h00, bpsk_out[7:0]};
            end
            2'b10: begin  // FM模式
                selected_data = fm_out;
            end
            default: begin // 保留模式
                selected_data = 16'h0000;
            end
        endcase
    end
    
    // 输出寄存器
    reg [15:0] d_out_reg;
    
    always @(posedge SysClk or negedge rst) begin
        if (!rst) begin
            d_out_reg <= 16'h0000;
        end else if (pll_locked) begin
            d_out_reg <= selected_data;
        end
    end
    
    // 输出赋值
    assign d_out = selected_data;
    
    // 状态LED指示
    assign status_led[0] = pll_locked;                    // LED0: PLL锁定指示
    assign status_led[1] = (mode_select == 2'b00);        // LED1: AM模式指示
    assign status_led[2] = (mode_select == 2'b01);        // LED2: BPSK模式指示


    
endmodule