module key_led (
    input clk,
    input rst_n,
    input [3:0] key,
    output reg [3:0] led
);
    reg [23:0] cnt;
    reg [1:0] led_state;

    //* count here
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 24'd0;
            led_state <= 2'b00;
        end 
        else if (cnt == 24'd10000000) begin
            cnt <= 24'd0;
            led_state <= led_state + 1;
        end 
        else begin
            cnt <= cnt + 1;
        end
    end

    // key action
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led <= 4'b0000;
        end
        else begin
            case (key)
                4'b1110: begin //! positive strip led
                    case(led_state)
                        2'b00: led <= 4'b0001;
                        2'b01: led <= 4'b0010;
                        2'b10: led <= 4'b0100;
                        2'b11: led <= 4'b1000;
                        default: led <= 4'b0000;
                    endcase
                end
                4'b1101: begin //! negative strip led
                    case(led_state)
                        2'b00: led <= 4'b1000;  
                        2'b01: led <= 4'b0100;
                        2'b10: led <= 4'b0010;
                        2'b11: led <= 4'b0001;
                        default: led <= 4'b0000;
                    endcase
                end 
                4'b1011: begin //! spark led
                    case(led_state)
                        2'b00: led <= 4'b1111;
                        2'b01: led <= 4'b0000;
                        2'b10: led <= 4'b1111;
                        2'b11: led <= 4'b0000;
                        default: led <= 4'b0000;
                    endcase
                end
                4'b0111: begin //! flash led
                        led <= 4'b1111;
                end
                default: led <= 4'b0000;
            endcase
        end
    end
endmodule