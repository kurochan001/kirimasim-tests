/*
:name: test_strong_weak_first_match_same_truth
:description: first_match keeps only the earliest match of a sequence, but strong(s) and strong(first_match(s)) succeed for the same attempts at the same ticks, and weak(s) and weak(first_match(s)) pass and fail for the same attempts at the same ticks (IEEE 1800-2023 Section 16.12.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_strong_weak_first_match_same_truth.expected
*/
// IEEE 1800-2023 §16.12.2: strong(s) is true when s has a nonempty match,
// and weak(s) is true unless some finite prefix shows that s cannot match.
// strong(s) and strong(first_match(s)) have the same truth value, and so do
// weak(s) and weak(first_match(s)), although first_match keeps only the
// earliest-ending matches (§16.9.8).
// s is a ##[1:3] b ##1 c. Tick k is at 10 * k + 5; a is high at ticks 1, 5
// and 9, b at 3, 4 and 10, c at 4, 5 and 11. The attempt at tick 1 has two
// matches, ending at 45 and 55, and first_match keeps the one at 45; the
// attempt at tick 5 finds no b up to tick 8 and fails there (85); the one at
// tick 9 matches at 115. Every attempt that starts without a fails at once.
// The cover sequences show the matches, the cover properties the successes
// of strong, and the assertions the passes and failures of weak; the times
// of each list are sorted and printed at the end.
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// reports no matches for the cover sequences, two successes (45 and 55) for
// the attempt at tick 1 of each cover property and assertion, and a failure
// at 95 instead of the second one at 85.

`timescale 1ns/1ns

module test_strong_weak_first_match_same_truth;
  logic clk = 0, a = 0, b = 0, c = 0;
  int q[string][$];
  string order[] = '{"matches of s", "matches of first_match(s)", "strong(s)",
                      "strong(first_match(s))", "weak(s) passes", "weak(first_match(s)) passes",
                      "weak(s) failures", "weak(first_match(s)) failures"};

  function automatic void hit(string name);
    int v[$];
    if (q.exists(name)) v = q[name];
    v.push_back(int'($time));
    q[name] = v;
  endfunction

  function automatic string times(string name);
    string s = "";
    int v[$];
    if (q.exists(name)) v = q[name];
    v.sort();
    foreach (v[i]) s = {s, $sformatf(" %0d", v[i])};
    return s;
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  c_seq: cover sequence (@(posedge clk) a ##[1:3] b ##1 c) hit("matches of s");
  c_seq_fm: cover sequence (@(posedge clk) first_match(a ##[1:3] b ##1 c))
    hit("matches of first_match(s)");
  c_strong: cover property (@(posedge clk) strong(a ##[1:3] b ##1 c)) hit("strong(s)");
  c_strong_fm: cover property (@(posedge clk) strong(first_match(a ##[1:3] b ##1 c)))
    hit("strong(first_match(s))");
  a_weak: assert property (@(posedge clk) weak(a ##[1:3] b ##1 c))
    hit("weak(s) passes"); else hit("weak(s) failures");
  a_weak_fm: assert property (@(posedge clk) weak(first_match(a ##[1:3] b ##1 c)))
    hit("weak(first_match(s)) passes"); else hit("weak(first_match(s)) failures");

  // a, b, c sampled at the ticks 0 to 13
  bit [2:0] table_abc[14] = '{3'b000, 3'b100, 3'b000, 3'b010, 3'b011, 3'b101, 3'b000,
                              3'b000, 3'b000, 3'b100, 3'b010, 3'b001, 3'b000, 3'b000};

  initial begin
    foreach (table_abc[k]) begin
      {a, b, c} = table_abc[k];
      #10;
    end
    foreach (order[i]) $display("%s: [%s ]", order[i], times(order[i]));
    $finish;
  end
endmodule
