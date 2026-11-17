// initalizes lcd on rising edge of lcd_init and sets lcd_ready once it's initialized
module LCD_init (
    input CLK100MHZ,
    input lcd_init,
    output reg lcd_enable = 0,
    output reg lcd_cmdMode = 1,
    output reg [7:0] lcd_data = 8'b0,
    output reg init_done = 0
);
  reg [3:0] lcd_init_seq = 4'b0000;

  reg lcd_init_old = 0;
  always @(posedge CLK100MHZ) begin
    if (lcd_init && !lcd_init_old) begin
       lcd_init_seq <= 4'b0001;
       init_done <= 0;
    end
    lcd_init_old <= lcd_init;

    // NOTE: this is the order that is specified in "Reset Function" of the HD44780U documentation
    if (lcd_init_seq == 4'b0) begin
      lcd_cmdMode <= 1;
      lcd_enable <= 1;
      lcd_data <= 8'h01;
      lcd_init_seq <= 4'b0001;
    end else if (lcd_init_seq[0]) begin
      lcd_data <= 8'h0F;
      lcd_init_seq <= lcd_init_seq << 1;
    end else if (lcd_init_seq[1]) begin
      lcd_data <= 8'h38;
      lcd_init_seq <= lcd_init_seq << 1;
    end else if (lcd_init_seq[2]) begin
      lcd_enable <= 0;
      init_done  <= 1;
    end else begin
      lcd_enable <= 0;
    end
  end
endmodule
