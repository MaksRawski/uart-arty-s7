module LCD_hello_world_tb;
  reg clk = 0;
  always #1 clk <= ~clk;

  reg lcd_init_done = 0;
  wire lcd_work_enable;
  wire lcd_work_cmdMode;
  wire [7:0] lcd_work_data;

  LCD_hello_world LCD_hello_world_inst (
      .CLK100MHZ(clk),
      .lcd_init_done(lcd_init_done),
      .lcd_enable(lcd_work_enable),
      .lcd_cmdMode(lcd_work_cmdMode),
      .lcd_data(lcd_work_data)
  );

  always @(posedge clk) if (lcd_work_enable) $write("%c", lcd_work_data);


  initial begin
    $dumpfile("LCD_hello_world_tb.vcd");
    $dumpvars(0, LCD_hello_world_tb);
    lcd_init_done <= 1;
    #22;
    $write("\n");
    $finish;
  end

endmodule
