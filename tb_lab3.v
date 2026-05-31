`timescale 1ns / 1ps

module tb_Lab3;

    // 1. Khai báo các tín hiệu
    reg clk;
    reg rst;
    reg sw;
    wire led;

    // 2. Gọi module cần kiểm tra (UUT)
    Lab3 uut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    // 3. Tạo xung nhịp (Clock) - Giả sử chu kỳ 10ns
    always #5 clk = ~clk;

    // 4. Khối mô phỏng thao tác nhấn/nhả
    initial begin
        // Bổ sung xuất file vcd để xem dạng sóng (Waveform)
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_Lab3);

        // Khởi tạo ban đầu
        clk = 0;
        rst = 0;
        sw  = 0;
        
        #20 rst = 1; // Tắt reset sau 20ns
        
        // Bắt đầu mô phỏng nhấn/nhả công tắc
        #20 sw = 1;  // Tại mốc 40ns: Sườn lên (0 -> 1). KỲ VỌNG: Đèn LED đổi trạng thái lần 1
        #50 sw = 0;  // Tại mốc 90ns: Sườn xuống (1 -> 0). KỲ VỌNG: Đèn LED giữ nguyên
        #50 sw = 1;  // Tại mốc 140ns: Sườn lên (0 -> 1). KỲ VỌNG: Đèn LED đổi trạng thái lần 2
        #50 sw = 0;  // (Đã thêm dấu chấm phẩy)
        #50;         // (Đã thêm dấu chấm phẩy)

        // Dừng mô phỏng
        $finish;     // Khuyên dùng $finish thay cho $stop để thoát hoàn toàn mô phỏng
    end

endmodule
