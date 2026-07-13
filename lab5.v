module Lab5(
        input wire clk,
        input wire rst,
        input wire [1:0] sw,
        output reg [3:0] led
);
    
    parameter CNT_MAX = 50;
    reg [31:0] cnt;
    reg done;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            done <= 0;
        end
        else begin
            if (cnt != CNT_MAX - 1) begin
                cnt <= cnt + 1;
                done <= 0;
            end
            else begin
                cnt <= 0;
                done <= 1;
            end
        end
    end

    reg led_toggle;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            led_toggle <= 0;
        end
        else begin
            if (done) begin
                led_toggle = ~led_toggle;
            end
        end
    end

    always @(*) begin
        led = 4'b0000;
        
        case ({sw})
            2'b00: led[0] = led_toggle;
            2'b10: led[1] = led_toggle;
            2'b01: led[2] = led_toggle;
            2'b11: led[3] = led_toggle; 
            default: begin
                led = 4'b0000;
            end
        endcase

    end
endmodule
