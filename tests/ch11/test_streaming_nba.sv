/*
:name: test_streaming_nba
:description: streaming operators + §10.4.2 NBA
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_nba.expected
*/
// IEEE 1800-2023 §11.4.14 streaming operators + §10.4.2 NBA

module tb;
  logic [31:0] data;
  logic [7:0] byte0, byte1, byte2, byte3;
  logic clk = 0;
  int pass_count = 0;
  int fail_count = 0;

  always #5 clk = ~clk;

  // Pack bytes into 32-bit using streaming NBA (big-endian, >> preserves order)
  task automatic test_streaming_nba_pack;
    @(posedge clk);
    {>>8{data}} <= {8'hAA, 8'hBB, 8'hCC, 8'hDD};
    @(posedge clk);
    if (data === 32'hAABBCCDD) begin
      $display("PASS: streaming NBA pack");
      pass_count++;
    end else begin
      $display("FAIL: streaming NBA pack: got %h", data);
      fail_count++;
    end
  endtask

  // Unpack 32-bit into bytes using streaming NBA
  task automatic test_streaming_nba_unpack;
    data = 32'h12345678;
    @(posedge clk);
    {>>{byte3, byte2, byte1, byte0}} <= data;
    @(posedge clk);
    if (byte3 === 8'h12 && byte2 === 8'h34 && byte1 === 8'h56 && byte0 === 8'h78) begin
      $display("PASS: streaming NBA unpack");
      pass_count++;
    end else begin
      $display("FAIL: streaming NBA unpack: got %h %h %h %h", byte3, byte2, byte1, byte0);
      fail_count++;
    end
  endtask

  // Half-word streaming NBA
  task automatic test_streaming_nba_halfword;
    @(posedge clk);
    {>>16{data}} <= {16'hFACE, 16'hCAFE};
    @(posedge clk);
    if (data === 32'hFACECAFE) begin
      $display("PASS: streaming NBA halfword");
      pass_count++;
    end else begin
      $display("FAIL: streaming NBA halfword: got %h", data);
      fail_count++;
    end
  endtask

  // Basic streaming assignment (non-NBA)
  task automatic test_streaming_blocking;
    logic [31:0] result;
    logic [7:0] a = 8'h11, b = 8'h22, c = 8'h33, d = 8'h44;
    {>>{result}} = {a, b, c, d};
    if (result === 32'h11223344) begin
      $display("PASS: streaming blocking assignment");
      pass_count++;
    end else begin
      $display("FAIL: streaming blocking: got %h", result);
      fail_count++;
    end
  endtask

  initial begin
    test_streaming_nba_pack();
    test_streaming_nba_unpack();
    test_streaming_nba_halfword();
    test_streaming_blocking();

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
