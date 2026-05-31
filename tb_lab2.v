`timescale 1ns / 1ps

module testbench();
    // Khai bao cac bien (reg) mo phong tin hieu vao tu 2 cong tac
    reg tb_switch_1;
    reg tb_switch_2;

    // Khai bao day (wire) de quan sat tin hieu ra tren LED
    wire tb_led_1;
    
    // Khoi tao module and_gate (Unit Under Test - UUT)
    and_gate uut(
        .switch_1(tb_switch_1),
        .switch_2(tb_switch_2),
        .led_1(tb_led_1)
    );

    initial begin
        // Tao file dump de quan sat dang song (waveform) tren phan mem
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        // Truong hop 1: Ca 2 cong tac deu khong nhan (muc 1) 
        // -> Ky vong: LED tat (0)
        tb_switch_1 = 1'b1;
        tb_switch_2 = 1'b1; 
        #20;

        // Truong hop 2: Ca 2 cong tac deu duoc nhan cung luc (muc 0) 
        // -> Ky vong: LED sang (1) dung voi yeu cau de bai
        tb_switch_1 = 1'b0;
        tb_switch_2 = 1'b0;
        #20;

        // Truong hop 3: Chi nhan cong tac 2 (switch_2 = 0) 
        // -> Ky vong: LED tat (0)
        tb_switch_1 = 1'b1;
        tb_switch_2 = 1'b0;
        #20;

        // Truong hop 4: Chi nhan cong tac 1 (switch_1 = 0) 
        // -> Ky vong: LED tat (0)
        tb_switch_1 = 1'b0;
        tb_switch_2 = 1'b1;
        #20;

        // Ket thuc mo phong
        $finish;
    end 
endmodule
