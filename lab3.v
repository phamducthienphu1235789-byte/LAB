module Lab3 (
    input wire clk, // Xung nhịp hệ thống
    input wire rst, // Nút reset (Active-Low)
    input wire sw,  // Nút nhấn (Công tắc)
    output reg led  // Đèn LED
);

    reg [1:0] sw_sync; // Thanh ghi 2 bit để lưu trạng thái hiện tại và trước đó của công tắc
    
    // Khối always hoạt động dựa trên sườn lên của clock hoặc sườn xuống của reset
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            // Trạng thái khởi tạo khi bị reset
            sw_sync <= 2'b11; // Mặc định công tắc ở trạng thái nhả (mức 1)
            led     <= 1'b0;  // Đèn LED tắt
        end else begin
            // Cập nhật trạng thái công tắc (dịch bit)
            sw_sync <= {sw_sync[0], sw}; 
            
            // Phát hiện sườn lên (0 -> 1): Lúc công tắc chuyển từ trạng thái 'đang nhấn' sang 'nhả ra'
            if (sw_sync == 2'b01) begin
                led <= ~led; // Đảo trạng thái đèn LED
            end
        end
    end
endmodule
