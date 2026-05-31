module and_gate (
    // Khai bao cac chan dau vao tu cong tac
    input wire switch_1,
    input wire switch_2,

    // Khai bao chan dau ra hien thi tren LED
    output wire led_1
);

    // Thuc hien phep toan AND voi cac tin hieu dau vao dao (Active-Low)
    assign led_1 = (~switch_1) & (~switch_2);

endmodule
