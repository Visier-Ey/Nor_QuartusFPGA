`timescale 1ns/1ps

module ask_modulator_tb;

    // Parameters
    parameter BASE_PHASE = 6553;
    parameter CLK_PERIOD = 20;  // 50MHz clock (20ns period)

    // Inputs
    reg sys_clk;
    reg sys_rst_n;
    reg data_in;

    // Outputs
    wire [7:0] da_data;
    wire da_clk;

    // Instantiate the Unit Under Test (UUT)
    ask_modulator #(
        .BASE_PHASE(BASE_PHASE)
    ) uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data_in(data_in),
        .da_data(da_data),
        .da_clk(da_clk)
    );

    // Clock generation
    always begin
        sys_clk = 1'b0;
        #(CLK_PERIOD/2);
        sys_clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    // Reset sequence
    initial begin
        sys_rst_n = 1'b0;
        data_in = 1'b0;
        #100;
        sys_rst_n = 1'b1;
        
        // Test sequence
        #800;
        data_in = 1'b1;  // First '1' bit
        #400;
        data_in = 1'b0;
        #800;
        data_in = 1'b1;  // Second '1' bit
        #400;
        data_in = 1'b0;
        #800;
        data_in = 1'b1;  // Third '1' bit
        #400;
        data_in = 1'b0;
        #800;
        
        // Longer test sequence
        repeat (10) begin
            data_in = 1'b1;
            #800;
            data_in = 1'b0;
            #800;
        end
        
        // Random data test
        repeat (20) begin
            data_in = $random;
            #800;
        end
        
        // #1000;
        // $finish;
    end

    // // Monitoring
    // initial begin
    //     $timeformat(-9, 0, " ns", 10);
    //     $monitor("At time %t: data_in = %b, da_data = %h, da_clk = %b", 
    //              $time, data_in, da_data, da_clk);
    // end

    // // VCD dump for waveform viewing
    // initial begin
    //     $dumpfile("psk_modulator_tb.vcd");
    //     $dumpvars(0, psk_modulator_tb);
    // end

endmodule