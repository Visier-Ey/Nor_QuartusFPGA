module gaussian_filter (
    input clk,
    input rst_n,
    input [7:0] data_in,
    output reg [7:0] filtered_out
);
    // ! gaussian filter coefficients
    // reg [7:0] coeff[0:2];
    
    // ! shift Window
    reg [7:0] shift_reg[3:0];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg[0] <= 8'd0;
            shift_reg[1] <= 8'd0;
            shift_reg[2] <= 8'd0;
            shift_reg[3] <= 8'd0;
            filtered_out <= 8'd0;
            // ! gaussian filter coefficients (BT=0.5, 8-bit quantized)
        end else begin
            shift_reg[0] <= shift_reg[1];
            shift_reg[1] <=  shift_reg[2];
            shift_reg[2] <=  shift_reg[3];
            shift_reg[3] <= data_in;
            // ! Gaussian filter operation
            // filtered_out <= shift_reg[0]>>'d2 + shift_reg[1]>>'d2 + shift_reg[2]>>'d1;
            filtered_out <= ({2'b0, shift_reg[1]} + {2'b0, shift_reg[2]} + {2'b0, shift_reg[0]} + {2'b0, shift_reg[3]})>>'d2;
        end
    end
endmodule