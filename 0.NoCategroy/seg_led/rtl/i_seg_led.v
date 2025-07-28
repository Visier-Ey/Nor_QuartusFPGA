module i_seg_led (
    input sys_clk,
    input sys_rst_n,
    input count_down,
    
    output reg [7:0] seg_led,
    output reg [5:0] seg_sel
);
    //! count down
    reg [31:0] count;  
    parameter ten = 4'b1010;
    reg [3:0] seg_data_1;
    reg [3:0] seg_data_2;
    reg [3:0] seg_data_3;
    reg [3:0] seg_data_4;
    reg [16:0] cnt;

    //! cycle light the segment led
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            seg_sel <= 6'b1111_10;  
            cnt <= ~0;
        end else begin
            cnt <= cnt - 1;
            if(cnt==0) seg_sel <= {seg_sel[4:0],seg_sel[5]};
        end
    end

    //! judge the count down
    always @(posedge sys_clk or negedge sys_rst_n) begin  
        if (!sys_rst_n) begin
            count <= 0;
        end else if (count_down) begin 
            count <= count + 1;
            if (count == 32'd10000) begin
                count <= 0;
            end
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            seg_data_1 <= 0;
            seg_data_2 <= 0;
            seg_data_3 <= 0;
            seg_data_4 <= 0;
        end
        else if (count_down) begin 
            //! full-adder
            if (count[3:0] == ten) seg_data_1 <= seg_data_1 + 1; 
            if (seg_data_1 == 4'b1001) begin
                seg_data_1 <= 0;
                seg_data_2 <= seg_data_2 + 1;
            end
            if (seg_data_2 == 4'b1001) begin
                seg_data_2 <= 0;
                seg_data_3 <= seg_data_3 + 1;
            end
            if (seg_data_3 == 4'b1001) begin
                seg_data_3 <= 0;
                seg_data_4 <= seg_data_4 + 1;
            end
            if (seg_data_4 == 4'b1001) begin
                seg_data_4 <= 0;
            end
        end
    end

    //! switch the display segment data
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) seg_led <= 8'b1111_1111;
        else begin
            case (seg_sel)
                6'b1111_10: seg_led <= get_seg_encoding(seg_data_1);
                6'b1111_01: seg_led <= get_seg_encoding(seg_data_2);
                6'b1110_11: seg_led <= get_seg_encoding(seg_data_3);
                6'b1101_11: seg_led <= get_seg_encoding(seg_data_4);
                default: seg_led <= 8'b1111_1111;
            endcase
        end
    end
    
    function [7:0] get_seg_encoding;
        input [3:0] num;
        begin
            case (num)
                4'd0: get_seg_encoding = ~8'h3f; // "0" (dp off)
                4'd1: get_seg_encoding = ~8'h06; // "1"
                4'd2: get_seg_encoding = ~8'h5b; // "2"
                4'd3: get_seg_encoding = ~8'h4f; // "3"
                4'd4: get_seg_encoding = ~8'h66; // "4"
                4'd5: get_seg_encoding = ~8'h6d; // "5"
                4'd6: get_seg_encoding = ~8'h7d; // "6"
                4'd7: get_seg_encoding = ~8'h07; // "7"
                4'd8: get_seg_encoding = ~8'h7f; // "8"
                4'd9: get_seg_encoding = ~8'h6f; // "9"
                default: get_seg_encoding = 8'h00; // close
            endcase
        end
    endfunction
endmodule