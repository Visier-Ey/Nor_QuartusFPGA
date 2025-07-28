module FIFO_rd (
    input clk,
    input rst_n,

    //! FIFO write interface
    input rd_full,
    input rd_empty,
    output rd_req,
    input [7:0] rd_data
);

    //! deal the one cycle delay
    reg rd_req_t;
    assign rd_req = rd_req_t & ~rd_empty;
    
    //! FIFO request signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rd_req_t <= 1'b0;
        else if (rd_empty) rd_req_t <= 1'b0;
        else if (rd_full) rd_req_t <= 1'b1;
    end

endmodule