`timescale 1ns/1ns // ! simulation time unit and precision
// ! #10 // delay for 10ns 

module ip_1port_ram_tb ();

    parameter T = 20; // 20ns;

    reg sys_clk;
    reg sys_rst_n;


    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        #(T + 1) sys_rst_n = 1'b1;
    end

    always begin
        #(T/2) sys_clk = ~sys_clk;
    end


    ip_1port_ram u_ip_1port_ram(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n)
    );

endmodule