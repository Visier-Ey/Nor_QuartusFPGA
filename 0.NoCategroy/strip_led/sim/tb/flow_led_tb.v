`timescale 1ns/1ns // ! simulation time unit and precision
// ! #10 // delay for 10ns 

module strip_led_tb ();

    parameter T = 20; // 20ns;

    reg sys_clk;
    reg sys_rst_n;

    wire [3:0] led;

    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        #(T + 1) sys_rst_n = 1'b1;
    end

    always begin
        #(T/2) sys_clk = ~sys_clk;
    end


    strip_led u_strip_led (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .led(led)
    );

endmodule