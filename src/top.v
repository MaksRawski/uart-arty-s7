module top (
    input CLK100MHZ,
    input [3:0] sw,
    input [3:0] btn,
    input uart_txd_in,
    output uart_rxd_out,
    output [10:0] ck_io,
    output [3:0] led
);

  reg lcd_clk = 0;
  reg [31:0] counter = 32'b0;
  always @(posedge CLK100MHZ) begin
    counter <= counter + 1;
    if (counter >= 100_000_000) begin
      counter   <= 0;
      lcd_clk <= !lcd_clk;
    end
  end
  assign led[0] = lcd_clk;

  reg [7:0] lcd_bus;
  reg lcd_enable, lcd_mode;
  task lcd_cmd;
    input [7:0] cmd;
    begin
      lcd_mode <= 1;
      lcd_enable <= 1;
      lcd_bus <= cmd;
    end
  endtask
  // task lcd_char;
  //   input [7:0] char;
  //   begin
  //     lcd_mode <= 0;
  //     lcd_enable <= 1;
  //     lcd_bus <= char;
  //   end
  // endtask

   // TODO: check the BUSY FLAG and wait on it

  // 00 -> cmd display on, cursor on, blinking on
  // 01 -> 8-bit operation, 2 line display, 5x8 character font
  // 10 -> clear display
  // 11 -> operating
  reg  [     1:0] lcd_init_seq;
  wire            rst;
  // reg             lcd_ready = 0;
   // TODO: obv this should be computed somehow
  reg  [     3:0] i = 9;
  reg  [10*8-1:0] str = {"It works!", 8'b0};
  reg [7:0]      char;
  always @(posedge lcd_clk) begin
    if (rst) begin
      lcd_init_seq <= 0;
      i <= 9;
    end

    case (lcd_init_seq)
      2'b00: begin
        lcd_cmd(8'h01);
        lcd_init_seq <= lcd_init_seq + 1;
      end
      2'b01: begin
        lcd_cmd(8'h0F);
        lcd_init_seq <= lcd_init_seq + 1;
      end
      2'b10: begin
        lcd_cmd(8'h38);
        lcd_init_seq <= lcd_init_seq + 1;
      end
      2'b11: begin
        // lcd_ready <= 1;
        char = { str[8*i+7], str[8*i+6], str[8*i+5], str[8*i+4], str[8*i+3], str[8*i+2], str[8*i+1], str[8*i] };
        if (char != 8'b0) begin
          lcd_bus <= char;
          lcd_enable <= 1'b1;
          lcd_mode <= 1'b0;
          i <= i - 1;
        end
        else lcd_enable <= 1'b0;
      end
    endcase
  end

  assign rst = btn[0];
  assign ck_io[10] = lcd_enable & lcd_clk;  // E
  assign ck_io[9] = !lcd_mode;  // RS
  assign ck_io[8] = 0;  // RW
  assign ck_io[0] = lcd_bus[7];
  assign ck_io[1] = lcd_bus[6];
  assign ck_io[2] = lcd_bus[5];
  assign ck_io[3] = lcd_bus[4];
  assign ck_io[4] = lcd_bus[3];
  assign ck_io[5] = lcd_bus[2];
  assign ck_io[6] = lcd_bus[1];
  assign ck_io[7] = lcd_bus[0];

endmodule
