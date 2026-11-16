module top (
    input CLK100MHZ,
    input [3:0] sw,
    input [3:0] btn,
    input uart_txd_in,
    output uart_rxd_out,
    inout [10:0] ck_io,
    output [3:0] led
);
  wire lcd_enable;
  wire lcd_cmdMode;
  wire [7:0] lcd_data;

  wire lcd_init_enable;
  wire lcd_init_cmdMode;
  wire [7:0] lcd_init_data;
  wire lcd_init_done;

  wire lcd_work_enable;
  wire lcd_work_cmdMode;
  wire [7:0] lcd_work_data;

  assign lcd_enable  = lcd_init_done ? lcd_work_enable  : lcd_init_enable;
  assign lcd_cmdMode = lcd_init_done ? lcd_work_cmdMode : lcd_init_cmdMode;
  assign lcd_data    = lcd_init_done ? lcd_work_data    : lcd_init_data;

  HD44780U HD44780U_inst (
      .CLK100MHZ(CLK100MHZ),
      .enable(lcd_enable),
      .cmdMode(lcd_cmdMode),
      .data(lcd_data),
      .D({ck_io[0], ck_io[1], ck_io[2], ck_io[3], ck_io[4], ck_io[5], ck_io[6], ck_io[7]}),
      .E(ck_io[10]),
      .RS(ck_io[9]),
      .RW(ck_io[8])
  );


  LCD_init LCD_init_inst (
      .CLK100MHZ(CLK100MHZ),
      .lcd_init(btn[0]),
      .lcd_enable(lcd_init_enable),
      .lcd_cmdMode(lcd_init_cmdMode),
      .lcd_data(lcd_init_data),
      .init_done(lcd_init_done)
  );

   assign led[0] = lcd_init_done;

  LCD_hello_world LCD_hello_world_inst (
      .CLK100MHZ(CLK100MHZ),
      .lcd_init_done(lcd_init_done),
      .lcd_enable(lcd_work_enable),
      .lcd_cmdMode(lcd_work_cmdMode),
      .lcd_data(lcd_work_data)
  );

endmodule
