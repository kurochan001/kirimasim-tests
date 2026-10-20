/*
:name: test_cover_disable_iff
:description: A cover property or cover sequence with disable iff does not succeed for an attempt that the disable condition cancels (IEEE 1800-2023 Section 16.14.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.3 16.12 16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cover_disable_iff.expected
*/
// IEEE 1800-2023 §16.12: disable iff (rst) cancels an evaluation attempt
// when rst is true at any time during it; §16.14.3: a cancelled attempt of a
// cover statement is not a success, so its pass statement does not run. a
// ##1 b matches at 25 while rst is still 1, and again at 55 after rst fell
// at 30: each cover succeeds once, at 55.

module test_cover_disable_iff;
  logic clk = 0, rst = 1, a = 0, b = 0;
  int n_prop = 0, n_seq = 0;
  int prop_at = -1, seq_at = -1;

  always #5 clk = ~clk;

  c_prop: cover property (@(posedge clk) disable iff (rst) a ##1 b) begin
    n_prop++;
    prop_at = $time;
  end

  c_seq: cover sequence (@(posedge clk) disable iff (rst) a ##1 b) begin
    n_seq++;
    seq_at = $time;
  end

  initial begin
    #10 a = 1;
    #10 a = 0;
    b = 1;
    #10 b = 0;
    rst = 0;
    #10 a = 1;
    #10 a = 0;
    b = 1;
    #10 b = 0;
    #10;
    $display("cover property: %0d at %0d, cover sequence: %0d at %0d", n_prop, prop_at, n_seq,
             seq_at);
    $finish;
  end
endmodule
