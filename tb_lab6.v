`timescale 1ns/1ps

module tb_memory_game;

    reg  CLK;
    reg  KEY0, KEY1, KEY2;
    wire LED0, LED1, LED2;
    wire SEG7_DIO, SEG7_RCLK, SEG7_SCLK;

    // SHOW_TIME=20, BLANK_TIME=10, DEBOUNCE_MAX=2 cho sim nhanh
    memory_game #(
        .SHOW_TIME(20),
        .BLANK_TIME(10),
        .DEBOUNCE_MAX(20'd2)
    ) uut (
        .CLK(CLK),
        .KEY0(KEY0), .KEY1(KEY1), .KEY2(KEY2),
        .LED0(LED0), .LED1(LED1), .LED2(LED2),
        .SEG7_DIO(SEG7_DIO),
        .SEG7_RCLK(SEG7_RCLK),
        .SEG7_SCLK(SEG7_SCLK)
    );

    initial CLK = 0;
    always #10 CLK = ~CLK;

    // Task bấm nút KEY0
    task press_key0;
        begin KEY0 = 0; #100; KEY0 = 1; #100; end
    endtask
    task press_key1;
        begin KEY1 = 0; #100; KEY1 = 1; #100; end
    endtask
    task press_key2;
        begin KEY2 = 0; #100; KEY2 = 1; #100; end
    endtask

    // Đợi hết SHOW và BLANK phase
    task wait_show_blank;
        begin #2000; end  // (20+10) chu kỳ * 20ns * vài lần
    endtask

    initial begin
        $dumpfile("tb_memory_game.vcd");
        $dumpvars(0, tb_memory_game);

        KEY0 = 1; KEY1 = 1; KEY2 = 1;
        #200;

        // Bắt đầu game
        $display("=== START GAME ===");
        press_key0;
        #2000;

        // Round 1: pattern[0]=LED0 → bấm KEY0
        $display("Round 1: press KEY0 (correct)");
        wait_show_blank;
        press_key0;
        #500;
        $display("LED0=%b LED1=%b LED2=%b", LED0, LED1, LED2);

        // Round 2: pattern[0..1]=LED0,LED1 → bấm KEY0, KEY1
        $display("Round 2: press KEY0, KEY1 (correct)");
        wait_show_blank;
        press_key0;
        #200;
        press_key1;
        #500;

        // Round 3: LED0,LED1,LED2 → KEY0,KEY1,KEY2
        $display("Round 3: press KEY0, KEY1, KEY2 (correct)");
        wait_show_blank;
        press_key0; #200;
        press_key1; #200;
        press_key2; #500;

        // Test thua: bấm sai ở round 4
        $display("Round 4: press WRONG key (KEY2 thay vi KEY0)");
        wait_show_blank;
        press_key2; // sai, phải là KEY0
        #500;
        $display("FAIL expected");

        // Restart
        #500;
        press_key0;
        $display("=== RESTART ===");
        #1000;

        $finish;
    end

endmodule
