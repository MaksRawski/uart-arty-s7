// Asynchronous "driver" for the HD44780U LCD.
// Async in the sense that commands/data can be pushed at 100MHZ rate and this module will handle busy flag waiting.
//
// Pins on the LCD and their connections to FPGA and the HD44780U module below:
// LCD:  | VSS | VDD |     V0      |  RS |  RW |  E |  D[0-7] |  A  |  K  |
// FPGA: | GND | 5V0 | POT 10K GND | .RS | .RW | .E |    .D   | 5V0 | GND |
//
// MIT License
//
// Copyright (c) 2026 Maksymilian Rawski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
module LCDCommandQueue (
    input            enqueue_clk,
    input            dequeue_clk,
    input      [8:0] data,         // MSB is cmdMode
    input            enqueue,
    input            dequeue,      // operates on rising edge
    output reg [8:0] out,
    output           non_empty
);
  reg [8:0] queue         [39:0];
  reg [5:0] enqueue_i = 0;
  reg [5:0] dequeue_i = 0;
  assign non_empty = enqueue_i != dequeue_i;

  always @(posedge enqueue_clk) begin
    if (enqueue) begin
      if ((enqueue_i + 1) % 40 == dequeue_i) $display("LCDCommandQueue is full!");
      else begin
        // $display("[%6t] Enqueuing: %9b", $time, data);
        queue[enqueue_i] <= data;
        enqueue_i <= (enqueue_i + 1) % 40;
      end
    end
  end
  always @(posedge dequeue_clk) begin
    // $display("enqueue_i = %d, dequeue_i", enqueue_i, dequeue_i);
    out = 9'bz;
    if (dequeue) begin
      if (!non_empty) $display("LCDCommandQueue is empty!");
      else begin
        // NOTE: if this was nonblocking then output would be only availble at the next clock edge
        out = queue[dequeue_i];
        dequeue_i <= (dequeue_i + 1) % 40;
        // $display("[%6t] Dequeuing: %9b", $time, out);
      end
    end
  end
endmodule

module HD44780U (
    input            CLK100MHZ,
    input            enable,
    input            cmdMode,
    input      [7:0] data,
    inout      [7:0] D,
    output reg       E = 0,
    output reg       RS = 1,
    output reg       RW = 0      // 0 - read, 1 - write
);
  // 100khz clk
  reg lcd_clk = 0;
  reg [31:0] counter = 32'b0;
  always @(posedge CLK100MHZ) begin
    counter = counter + 1;
    if (counter == 500) begin
      counter <= 0;
      lcd_clk <= ~lcd_clk;
    end
  end

  reg D_write = 0;
  reg [7:0] D_data = 8'b0;
  assign D = D_write ? D_data : 8'bz;

  wire [8:0] queue_out;
  wire       queue_non_empty;
  reg        queue_dequeue = 0;


  LCDCommandQueue LCDCommandQueue_inst (
      .enqueue_clk(CLK100MHZ),
      .dequeue_clk(lcd_clk),
      .data({cmdMode, data}),
      .enqueue(enable),
      .dequeue(queue_dequeue),
      .out(queue_out),
      .non_empty(queue_non_empty)
  );

  reg lcd_busy = 1;
  reg read_busy_flag = 1;
  reg dequeue_ready = 0;
  always @(posedge lcd_clk) begin
    queue_dequeue <= 0;
    if (read_busy_flag) begin
      RW <= 1;
      RS <= 0;
      D_write <= 0;
      E <= 1;
      read_busy_flag <= 0;
    end else lcd_busy <= D[7];

    if (!lcd_busy && queue_non_empty) begin
      // TODO: we should wait for one cycle after setting queue_dequeue, so as to give queue_out time 
      if (!dequeue_ready) begin
        queue_dequeue <= 1;
        dequeue_ready <= 1;
      end else begin
        dequeue_ready <= 0;
        RW <= 1;
        RS <= queue_out[8];
        if (queue_out[8]) $display("LCD COMMAND: %2x", queue_out[7:0]);
        else $write("%c", queue_out[7:0]);
        D_write <= 1;
        D_data <= queue_out[7:0];
        E <= 1;
        read_busy_flag <= 1;
      end
    end
  end
endmodule
