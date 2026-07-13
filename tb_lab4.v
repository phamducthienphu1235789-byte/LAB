`timescale 1ns / 1ps

module tb_Lab4; 
    // 1. Khai báo các tín hiệu kết nối với UUT
    reg clk;
    reg rst;
    reg sw;
    wire led;

    Lab4 uut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        // --- Khởi tạo ban đầu ---
        clk = 0;
        rst = 0;
        sw = 0;
        #20;
        
        rst = 1; // Tắt reset, mạch bắt đầu hoạt động ổn định
        #20;
        
        // Thao tác 1: Nhấn nút 
        sw = 1; 
        #200; 
        
        // Thao tác 2: Nhả nút (chuyển từ 1 -> 0)
        sw = 0;
        #200;
        // Thao tác 3: Nhấn lại lần nữa
        sw = 1;
        #200;
        
        // Thao tác 4: Nhả lần nữa
        sw = 0;
        #200;

        $stop; 
    end

endmodule
