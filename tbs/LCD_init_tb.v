module LCD_init_tb;
  reg clk = 0;
  always #1 clk <= ~clk;

  wire       lcd_init_enable;
  wire       lcd_init_cmdMode;
  wire [7:0] lcd_init_data;
  wire       lcd_init_done;

  LCD_init LCD_init_inst (
      .CLK100MHZ(clk),
      .lcd_init(1'b1),
      .lcd_enable(lcd_init_enable),
      .lcd_cmdMode(lcd_init_cmdMode),
      .lcd_data(lcd_init_data),
      .init_done(lcd_init_done)
  );

  always @(posedge clk) begin
    if (lcd_init_enable) $display("%8b", lcd_init_data);
    if (!lcd_init_cmdMode) $display("ERROR: cmdMode not set");
  end

  initial begin
    $dumpfile("LCD_init.vcd");
    $dumpvars(0, LCD_init_tb);
    #20;
    $finish;
  end

endmodule
