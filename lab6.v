module memory_game #(
    parameter CLK_FREQ    = 50_000_000,
    parameter SHOW_TIME   = 50_000_000,  // 1s hiển thị mỗi LED
    parameter BLANK_TIME  = 25_000_000,  // 0.5s khoảng trắng giữa các LED
    parameter DEBOUNCE_MAX = 20'd999_999
)(
    input  CLK,
    input  KEY0, KEY1, KEY2,
    output LED0, LED1, LED2,
    output SEG7_DIO,
    output SEG7_RCLK,
    output SEG7_SCLK
);

    // ── Pattern cố định 7 bước (0=LED0, 1=LED1, 2=LED2) ──
    reg [1:0] pattern [0:6];
    initial begin
        pattern[0] = 2'd0;
        pattern[1] = 2'd1;
        pattern[2] = 2'd2;
        pattern[3] = 2'd0;
        pattern[4] = 2'd2;
        pattern[5] = 2'd1;
        pattern[6] = 2'd0;
    end

    // ── Debounce 3 nút ────────────────────────────────────
    reg [19:0] db_cnt0 = 0, db_cnt1 = 0, db_cnt2 = 0;
    reg sw0 = 1'b1, sw1 = 1'b1, sw2 = 1'b1;
    reg s00 = 1'b1, s01 = 1'b1;
    reg s10 = 1'b1, s11 = 1'b1;
    reg s20 = 1'b1, s21 = 1'b1;

    always @(posedge CLK) begin s00 <= KEY0; s01 <= s00; end
    always @(posedge CLK) begin s10 <= KEY1; s11 <= s10; end
    always @(posedge CLK) begin s20 <= KEY2; s21 <= s20; end

    always @(posedge CLK) begin
        if (s01 != sw0) begin
            db_cnt0 <= db_cnt0 + 1;
            if (db_cnt0 == DEBOUNCE_MAX) begin sw0 <= s01; db_cnt0 <= 0; end
        end else db_cnt0 <= 0;
    end
    always @(posedge CLK) begin
        if (s11 != sw1) begin
            db_cnt1 <= db_cnt1 + 1;
            if (db_cnt1 == DEBOUNCE_MAX) begin sw1 <= s11; db_cnt1 <= 0; end
        end else db_cnt1 <= 0;
    end
    always @(posedge CLK) begin
        if (s21 != sw2) begin
            db_cnt2 <= db_cnt2 + 1;
            if (db_cnt2 == DEBOUNCE_MAX) begin sw2 <= s21; db_cnt2 <= 0; end
        end else db_cnt2 <= 0;
    end

    // Edge detect
    reg sw0_r = 1'b1, sw1_r = 1'b1, sw2_r = 1'b1;
    always @(posedge CLK) begin
        sw0_r <= sw0; sw1_r <= sw1; sw2_r <= sw2;
    end
    wire press0 = (sw0_r == 1'b1) && (sw0 == 1'b0);
    wire press1 = (sw1_r == 1'b1) && (sw1 == 1'b0);
    wire press2 = (sw2_r == 1'b1) && (sw2 == 1'b0);

    // ── State machine ─────────────────────────────────────
    localparam IDLE       = 3'd0,
               SHOW       = 3'd1,
               BLANK      = 3'd2,
               WAIT_INPUT = 3'd3,
               WIN        = 3'd4,
               FAIL       = 3'd5;

    reg [2:0]  state      = IDLE;
    reg [2:0]  round      = 3'd1;  // round hiện tại (1→7)
    reg [2:0]  show_idx   = 3'd0;  // đang hiển thị pattern thứ mấy
    reg [2:0]  input_idx  = 3'd0;  // player đang nhập thứ mấy
    reg [25:0] timer      = 0;
    reg [1:0]  led_r      = 2'd3;  // 3 = tắt
    reg [3:0]  score      = 4'd0;

    always @(posedge CLK) begin
        case (state)
            IDLE: begin
                led_r     <= 2'd3;
                show_idx  <= 0;
                input_idx <= 0;
                score     <= 4'd0;
                timer     <= 0;
                if (press0 || press1 || press2)
                    state <= SHOW;
            end

            SHOW: begin
                led_r <= pattern[show_idx];
                timer <= timer + 1;
                if (timer == SHOW_TIME - 1) begin
                    timer    <= 0;
                    led_r    <= 2'd3;
                    state    <= BLANK;
                end
            end

            BLANK: begin
                led_r <= 2'd3;
                timer <= timer + 1;
                if (timer == BLANK_TIME - 1) begin
                    timer <= 0;
                    if (show_idx == round - 1) begin
                        show_idx  <= 0;
                        input_idx <= 0;
                        state     <= WAIT_INPUT;
                    end else begin
                        show_idx <= show_idx + 1;
                        state    <= SHOW;
                    end
                end
            end

            WAIT_INPUT: begin
                led_r <= 2'd3;
                if (press0 || press1 || press2) begin
                    // Kiểm tra đúng/sai
                    if ((press0 && pattern[input_idx] == 2'd0) ||
                        (press1 && pattern[input_idx] == 2'd1) ||
                        (press2 && pattern[input_idx] == 2'd2)) begin
                        // Đúng
                        if (input_idx == round - 1) begin
                            // Hết pattern của round này
                            score <= score + 1;
                            if (round == 3'd7)
                                state <= WIN;
                            else begin
                                round    <= round + 1;
                                show_idx <= 0;
                                state    <= SHOW;
                            end
                        end else
                            input_idx <= input_idx + 1;
                    end else begin
                        // Sai
                        state <= FAIL;
                    end
                end
            end

            WIN: begin
                led_r <= 2'd3;
                score <= 4'd10; // hiển thị A
                if (press0 || press1 || press2) begin
                    round <= 3'd1;
                    state <= IDLE;
                end
            end

            FAIL: begin
                led_r <= 2'd3;
                score <= 4'd11; // hiển thị F
                if (press0 || press1 || press2) begin
                    round <= 3'd1;
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end

    assign LED0 = (led_r == 2'd0) ? 1'b1 : 1'b0;
    assign LED1 = (led_r == 2'd1) ? 1'b1 : 1'b0;
    assign LED2 = (led_r == 2'd2) ? 1'b1 : 1'b0;

    // ── 7-seg decode (common anode) ───────────────────────
    // score: 0-9 = số, 10 = A, 11 = F
    function [6:0] seg_decode;
        input [3:0] d;
        case (d)
            4'd0:  seg_decode = 7'b1000000;
            4'd1:  seg_decode = 7'b1111001;
            4'd2:  seg_decode = 7'b0100100;
            4'd3:  seg_decode = 7'b0110000;
            4'd4:  seg_decode = 7'b0011001;
            4'd5:  seg_decode = 7'b0010010;
            4'd6:  seg_decode = 7'b0000010;
            4'd7:  seg_decode = 7'b1111000;
            4'd8:  seg_decode = 7'b0000000;
            4'd9:  seg_decode = 7'b0010000;
            4'd10: seg_decode = 7'b0001000; // A
            4'd11: seg_decode = 7'b0001110; // F
            default: seg_decode = 7'b1111111;
        endcase
    endfunction

    wire [7:0] seg_byte = {1'b1, seg_decode(score)};
    wire [7:0] sel_byte = 8'b0000_0001;
    wire [15:0] r_data  = {seg_byte, sel_byte};

    // ── 74HC595 driver ────────────────────────────────────
    reg sck_r = 0;
    always @(posedge CLK) sck_r <= ~sck_r;
    wire sck_plus = (sck_r == 1'b1);

    reg [5:0] SHCP_EDGE_CNT = 0;
    always @(posedge CLK) begin
        if (sck_plus) begin
            if (SHCP_EDGE_CNT == 6'd32) SHCP_EDGE_CNT <= 0;
            else SHCP_EDGE_CNT <= SHCP_EDGE_CNT + 1'b1;
        end
    end

    reg ds_r = 0, sh_cp_r = 0, st_cp_r = 0;
    always @(posedge CLK) begin
        case (SHCP_EDGE_CNT)
            0:  begin sh_cp_r<=0; st_cp_r<=0; ds_r<=r_data[15]; end
            1:  begin sh_cp_r<=1; end
            2:  begin sh_cp_r<=0; ds_r<=r_data[14]; end
            3:  begin sh_cp_r<=1; end
            4:  begin sh_cp_r<=0; ds_r<=r_data[13]; end
            5:  begin sh_cp_r<=1; end
            6:  begin sh_cp_r<=0; ds_r<=r_data[12]; end
            7:  begin sh_cp_r<=1; end
            8:  begin sh_cp_r<=0; ds_r<=r_data[11]; end
            9:  begin sh_cp_r<=1; end
            10: begin sh_cp_r<=0; ds_r<=r_data[10]; end
            11: begin sh_cp_r<=1; end
            12: begin sh_cp_r<=0; ds_r<=r_data[9];  end
            13: begin sh_cp_r<=1; end
            14: begin sh_cp_r<=0; ds_r<=r_data[8];  end
            15: begin sh_cp_r<=1; end
            16: begin sh_cp_r<=0; ds_r<=r_data[7];  end
            17: begin sh_cp_r<=1; end
            18: begin sh_cp_r<=0; ds_r<=r_data[6];  end
            19: begin sh_cp_r<=1; end
            20: begin sh_cp_r<=0; ds_r<=r_data[5];  end
            21: begin sh_cp_r<=1; end
            22: begin sh_cp_r<=0; ds_r<=r_data[4];  end
            23: begin sh_cp_r<=1; end
            24: begin sh_cp_r<=0; ds_r<=r_data[3];  end
            25: begin sh_cp_r<=1; end
            26: begin sh_cp_r<=0; ds_r<=r_data[2];  end
            27: begin sh_cp_r<=1; end
            28: begin sh_cp_r<=0; ds_r<=r_data[1];  end
            29: begin sh_cp_r<=1; end
            30: begin sh_cp_r<=0; ds_r<=r_data[0];  end
            31: begin sh_cp_r<=1; end
            32: begin st_cp_r<=1; end
            default: begin st_cp_r<=0; ds_r<=0; sh_cp_r<=0; end
        endcase
    end

    assign SEG7_DIO  = ds_r;
    assign SEG7_SCLK = sh_cp_r;
    assign SEG7_RCLK = st_cp_r;

endmodule
