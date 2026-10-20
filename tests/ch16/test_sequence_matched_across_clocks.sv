/*
:name: test_sequence_matched_across_clocks
:description: matched keeps the end point of a sequence on one clock until the next tick of another clock, where a property can use it (IEEE 1800-2023 Section 16.13.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.5 16.13.6 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_matched_across_clocks.expected
*/
// IEEE 1800-2023 §16.13.5, §16.13.6: s.matched, used under a clock other than
// the clock of s, is true at the first tick of that clock after s reaches an
// end point, and false at later ticks. s_src, on posedge clk1 at 5, 15, 25,
// ..., matches a ##1 b at 25. posedge clk2 comes at 20, 60 and 100, so the
// cover property on clk2 (16.14.3) succeeds only at 60.

module test_sequence_matched_across_clocks;
  logic clk1 = 0, clk2 = 0, a = 0, b = 0;
  int hits = 0;
  string hit_times = "";

  always #5 clk1 = ~clk1;
  always #20 clk2 = ~clk2;

  sequence s_src;
    @(posedge clk1) a ##1 b;
  endsequence

  c_dst: cover property (@(posedge clk2) s_src.matched) begin
    hits++;
    hit_times = {hit_times, $sformatf(" %0d", $time)};
  end

  initial begin
    #12 a = 1;
    #10 a = 0;
    b = 1;
    #10 b = 0;
    #88 $display("matched seen %0d time(s), at%s", hits, hit_times);
    $finish;
  end
endmodule
