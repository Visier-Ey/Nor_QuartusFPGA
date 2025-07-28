`timescale 1us/1us

module key_led_tb ();
    reg clk;
    reg rst_n;
    reg [3:0] key;
    wire [3:0] led;

    key_led uut (
        .clk(clk),
        .rst_n(rst_n),
        .key(key),
        .led(led)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        key = 4'b0000;

        #5 rst_n = 1; // Release reset
        #5 key = 4'b0001; // Press key 1
        #10 key = 4'b0010; // Press key 2
        #10 key = 4'b0100; // Press key 3
        #10 key = 4'b1000; // Press key 4
        #10 key = 4'b0000; // Release all keys

        #50 $finish; // End simulation
    end

    always begin
        #5 clk = ~clk; // Generate clock signal
    end
endmodule