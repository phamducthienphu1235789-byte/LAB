`timescale 1ns / 1ps 

module testbench();
    // Khai bao cac bien (reg) de mo phong tin hieu dau vao tu cong tac
    reg tb_switch_1;
    reg tb_switch_2;
    reg tb_switch_3;

    // Khai bao cac day (wire) de quan sat tin hieu dau ra tren LED
    wire tb_led_1;
    wire tb_led_2;
    wire tb_led_3;

    // Khoi tao module led_blink (Unit Under Test - UUT) de kiem thu
    led_blink uut (
        .switch_1(tb_switch_1), 
        .switch_2(tb_switch_2),
        .switch_3(tb_switch_3),
        .led_1(tb_led_1),      
        .led_2(tb_led_2),
        .led_3(tb_led_3)
    );

    initial begin 
        // Tao file dump de quan sat dang song (waveform) khi chay mo phong
        $dumpfile("dump.vcd"); 
        $dumpvars(0, testbench);  
        
        // Buoc 1: Trang thai ban dau (Tat ca cac switch o muc 1 - chua nhan)
        tb_switch_1 = 1'b1;
        tb_switch_2 = 1'b1;
        tb_switch_3 = 1'b1;
        #20; // Doi 20ns
        
        // Buoc 2: Nhan switch 1 (dua ve muc 0)
        tb_switch_1 = 1'b0;
        tb_switch_2 = 1'b1;
        tb_switch_3 = 1'b1;
        #40; // Doi 40ns 
        
        // Buoc 3: Nha switch 1, dong thoi nhan switch 2 va 3
        tb_switch_1 = 1'b1;
        tb_switch_2 = 1'b0;
        tb_switch_3 = 1'b0;
        #50; // Doi 50ns 
        
        // Buoc 4: Nha tat ca cac switch ve trang thai ban dau
        tb_switch_1 = 1'b1;
        tb_switch_2 = 1'b1;
        tb_switch_3 = 1'b1;
        #20; // Doi 20ns
        
        // Ket thuc qua trinh mo phong
        $finish;
    end
endmodule
