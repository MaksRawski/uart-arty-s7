module LCD_hello_world (
    input CLK100MHZ,
    input lcd_init_done,
    output reg lcd_enable = 0,
    output reg lcd_cmdMode,
    output reg [7:0] lcd_data
);
  reg [     3:0] i = 9;
  reg [10*8-1:0] str = {"It works!", 8'b0};
  reg [     7:0] char;
  always @(posedge CLK100MHZ) begin
    char = {
      str[8*i+7], str[8*i+6], str[8*i+5], str[8*i+4], str[8*i+3], str[8*i+2], str[8*i+1], str[8*i]
    };
    if (lcd_init_done) begin
      if (char != 8'b0) begin
        lcd_data   <= char;
        lcd_enable <= 1;
        lcd_cmdMode = 0;
        i <= i - 1;
      end else begin
        lcd_enable <= 0;
      end
    end else begin
      i = 9;
    end
  end
endmodule
