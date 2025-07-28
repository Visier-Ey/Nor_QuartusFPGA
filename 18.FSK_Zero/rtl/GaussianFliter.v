module gaussian_filter(
    input clk,
    input rst_n,
    input data_in,
    output reg [10:0] filtered_out
);
    // ! gaussian filter coefficients (BT=0.5 standard)
    // ! 5-tap symmetric coefficients for BT=0.5 GFSK
    localparam [7:0] COEFF0 = 8'd4;   // 抽头0
    localparam [7:0] COEFF1 = 8'd20;  // 抽头1
    localparam [7:0] COEFF2 = 8'd52;  // 抽头2 (中心抽头) 
    localparam [7:0] COEFF3 = 8'd20;  // 抽头3
    localparam [7:0] COEFF4 = 8'd4;   // 抽头4
    
    // ! shift Window (5-tap delay line) 
    // ! optimized the multiplexer
    reg [4:0] shift_reg;

    wire [7:0] prod0 = shift_reg[0] ? (COEFF0) : 0;
    wire [7:0] prod1 = shift_reg[1] ? (COEFF1) : 0;
    wire [7:0] prod2 = shift_reg[2] ? (COEFF2) : 0;
    wire [7:0] prod3 = shift_reg[3] ? (COEFF3) : 0;
    wire [7:0] prod4 = shift_reg[4] ? (COEFF4) : 0;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // ! Initialize all registers
            shift_reg <= 0;
            filtered_out <= 0;
        end else begin
            // ! Update shift register (pipeline)
            shift_reg <= {shift_reg[3:0], data_in};
            
            // ! Gaussian filter operation
            // ! Sum of products with normalization (sum=100)
            filtered_out <= {(prod0 + prod1 + prod2 + prod3 + prod4),3'b000};
        end
    end
    
    // ! Note: Output needs 2.56x gain compensation (100/256)
    // ! Can be implemented in NCO frequency control scaling
endmodule