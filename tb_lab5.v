`timescale 1ns / 1ps

module tb_Lab5;

    // 1. Khai báo các tín hiệu
    reg clk;
    reg rst;
    reg [1:0] sw;
    wire [3:0] led;

    // 2. Gọi module cần kiểm tra (UUT)
    Lab5 uut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    // 3. Tạo xung nhịp (Clock) - Giả sử chu kỳ 10ns
    always #5 clk = ~clk;

    // 4. Khối mô phỏng thao tác nhấn/nhả
    initial begin
        // Khởi tạo ban đầu
        clk = 0;
        rst = 1;
        sw  = 0;
        #20 
        rst = 0; // Tắt reset sau 20ns
        #20
        // TH1:D1=ON;D2&D4&D3=OFF
        sw = 2'b00;
        #600        
        // TH2:D2=ON;D1&D4&D3=OFF
        sw = 2'b10;
        #600 
        //TH3:D3=ON;D1&D4&D2=OFF
        sw = 2'b01; // Nhả nút lần 2
        #600 
        //TH4:D4=ON;D1&D3&D2=OFF
        sw = 2'b11;
        #600
        // $finish;
        $stop;
    end

endmodule
