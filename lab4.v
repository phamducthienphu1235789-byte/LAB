module Lab4(
    input clk,
    input rst,
    input sw,
    output reg led
);
    parameter MAX_CNT = 500_000;
    reg [23:0] cnt;
    reg sw_last;
    reg sw_stable;
    
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            cnt <= 0;
            sw_last <= 1'b1;
            sw_stable <= 1'b1;
        end         
        else begin
            if(sw != sw_last) begin
                cnt <= 0;
            end
            else if(cnt < MAX_CNT) begin
                cnt <= cnt + 1;
            end
            else begin
                sw_stable <= sw;
            end
            sw_last <= sw;
        end
    end


    reg sw_stable_current;
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            led <= 1'b1;
            sw_stable_current <= 1'b1;
        end
        else begin
            sw_stable_current <= sw_stable;
            if(!sw_stable && sw_stable_current) begin
                led <= ~led;
            end
        end
    end

endmodule
