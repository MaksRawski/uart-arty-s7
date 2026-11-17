module top_tb;

  reg         clk = 0;
  reg         rst = 0;
  wire [10:0] io;
  reg  [10:0] io_val = 11'bz;
  reg         io_write = 0;
  assign io = io_write ? io_val : 11'bz;
  wire RW = io[8];
  wire RS = io[9];
  wire E = io[10];


  top DUT (
      .CLK100MHZ(clk),
      .btn({3'b000, rst}),
      .ck_io(io)
  );

  always #1 clk <= ~clk;

  // TODO: every second time busy flag is checked return 1
  reg [3:0] busy_flag_checks = 0;
  // NOTE: lcd clocks slower
  always @(posedge clk) begin
    if (RW & ~RS & E) begin
      busy_flag_checks <= busy_flag_checks + 1;
      io_write <= 1;
      // NOTE: because the io order is swapped in top, D7 is actually io[0]
      if ($time < 10_000) io_val[0] <= 1;  // set busy flag
      else io_val[0] <= 0;  // remove busy flag
    end else begin
      io_write <= 0;
    end

  end

  initial begin
    $dumpfile("top_tp.vcd");
    $dumpvars(0, top_tb);
    #100_000;
    $write("\n");
    $finish;
  end
endmodule
