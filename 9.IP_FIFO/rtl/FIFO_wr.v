module FIFO_wr (
    input clk,
    input rst_n,

    //! FIFO write interface
    input wr_full,
    input wr_empty,
    output wr_req,
    output reg[7:0] wr_data
);

    //! deal the one cycle delay
    reg wr_req_t;
    assign wr_req = wr_req_t & ~wr_full;
    
    //! FIFO request signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wr_req_t <= 1'b0;
        else if (wr_full) wr_req_t <= 1'b0;
        else if (wr_empty) wr_req_t <= 1'b1;
    end

    //! FIFO write data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wr_data <= 8'b0;
        else if (wr_req) wr_data <= wr_data + 1'b1; // Increment data for demonstration
        else wr_data <= 8'd0;
    end
endmodule