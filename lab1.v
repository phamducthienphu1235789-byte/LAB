module led_blink (
    // Khai bao cac chan dau vao (tu cong tac)
    input wire switch_1,
    input wire switch_2,
    input wire switch_3,

    // Khai bao cac chan dau ra (ra den LED)
    output wire led_1,
    output wire led_2,
    output wire led_3
);

    // Gan chan logic
    // Dau nguyen (~) duoc su dung de dao trang thai (thuong dung cho mach Active-Low)
    assign led_1 = ~switch_1;
    assign led_2 = ~switch_2;
    assign led_3 = ~switch_3;

endmodule
