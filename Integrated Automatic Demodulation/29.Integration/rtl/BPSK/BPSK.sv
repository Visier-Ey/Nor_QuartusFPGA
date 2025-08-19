module BPSK (
    input clk,          
    input rst_n,             
    input [7:0] d_in,     
    output signed [7:0] d_out
);  
    // ! ================================ Some Brief Here ================================  

    // ! Quadrature 
    // ! Inphase -> 0

    // ! ============================= Global Parameter Here =============================

    // * System Clock and Reset
    wire SysClk;
    wire FirClk;
    wire NcoClk;
    assign SysClk = clk;
    assign FirClk = clk;
    assign NcoClk = clk;
    
    // * AD DA
    wire signed [7:0] _ad_data;
    assign _ad_data = d_in - 128; 

    // * NCO
    wire signed [7:0] nco_sin, nco_cos; 
    wire [7:0] _nco_sin, _nco_cos; 

    assign nco_sin = $signed(_nco_sin - 8'd128); 
    assign nco_cos = $signed(_nco_cos - 8'd128); 

    // * Mixer
    wire signed [15:0] I_mix, Q_mix;

    // * FIR
    reg signed [15:0] I_filtered, Q_filtered;
    reg signed [15:0] _I_filtered, _Q_filtered;
    assign I_filtered = _I_filtered ;  // * cost
    assign Q_filtered = _Q_filtered ;  // * sint

    // * Phase Error
    wire signed [31:0] phase_error; 
    wire signed [31:0] _phase_error;
    wire signed [31:0] phase_adj;
    wire signed [31:0] fwc; 
    assign _phase_error = -(I_filtered * Q_filtered); 
    assign phase_error = _phase_error; 
    assign phase_adj = {1'b0,fwc[30:0]};

    // ! ============================= Moudle Here =============================

    // --- 1. 正交下变频（8-bit Mixer） ---    
    mixer u_mixer (
        .clk(SysClk),
        .rst_n(rst_n),
        .adc_data(_ad_data),
        .nco_sin(nco_sin),  
        .nco_cos(nco_cos),  
        .I_out(I_mix),
        .Q_out(Q_mix)
    );

    //--- 2. 低通滤波（优化为8-bit输入） ---
    FIR16 fir_I (
        .clk(FirClk),
        .fir_in(I_mix>>>8), 
        .fir_out(_I_filtered)
    );
    
    FIR16 fir_Q (
        .clk(FirClk),
        .fir_in(Q_mix>>>8), 
        .fir_out(_Q_filtered)
    );

    // --- 3. 有效性控制 ---
    reg [6:0] delay_cnt;
    reg valid;

    always @(posedge SysClk or negedge rst_n) begin
        if (!rst_n) begin
            delay_cnt <= 0;
            valid <= 0;
        end else begin
            if (delay_cnt < 7'd127) begin
                delay_cnt <= delay_cnt + 1;
            end else begin
                valid <= 1;  
            end
        end
    end

    // --- 4. 环路滤波 ---
    loop_filter#(
        .INIT_FREQ(32'd42949673)
    ) u_loop_filter (
        .clk(SysClk),
        .rst_n(rst_n),    
        .valid(valid), 
        .phase_error(phase_error),  
        .freq_ctrl(fwc)
    );


    // --- 5. 8位NCO（节省资源） ---
    _NCO #(
        .BASE_PHASE(0)
    ) ncoSin (
        .clk(NcoClk),
        .reset_n(rst_n),
        .phi_inc_i(phase_adj), 
        .nco_out(_nco_sin), 
        .out_valid()
    );

    _NCO #(
        .BASE_PHASE(32'h4000_0000) // * 180deg flipped
    ) ncoCos (
        .clk(NcoClk),
        .reset_n(rst_n),
        .phi_inc_i(phase_adj), 
        .nco_out(_nco_cos),
        .out_valid()
    );

  // ! ============================= Output Port Here =============================

    assign d_out = (I_filtered >>> 8);
endmodule