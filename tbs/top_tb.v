module top_tb;

  reg         clk = 0;
  reg         rst = 0;
  wire [10:0] io;
  reg  [10:0] io_val;
  reg         io_write;
  assign io = io_write ? io_val : 11'bz;


  top DUT (
      .CLK100MHZ(clk),
      .btn({3'b000, rst}),
      .ck_io(io)
  );

  always #1 clk <= ~clk;

  // TODO: every second time busy flag is checked return 1

  initial begin
    $dumpfile("top_tp.vcd");
    $dumpvars(0, top_tb);
    io_write <= 1;
    io_val <= 11'bzzz_1000_0000; // busy
    #100;
    io_val <= 11'bzzz_0000_0000; // not busy

    #100;
    // io_write <= 0; // readable io

    #1000;
    $finish;
  end
endmodule
