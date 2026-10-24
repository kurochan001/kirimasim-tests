/*
:name: test_sequence_empty_match_fusion
:description: an empty sequence joined with ##0 to another sequence, on its left or on its right and also to another empty sequence, never matches, while with ##n for n > 0 it shortens the delay by one tick; a[*0] and a[*0:0] both match as the empty sequence (IEEE 1800-2023 Section 16.9.2.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2.1 16.9.2 16.7 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_empty_match_fusion.expected
*/
// IEEE 1800-2023 §16.9.2.1: a[*0] is the empty sequence, which matches only
// over zero ticks (§16.7). (empty ##0 seq) and (seq ##0 empty) do not match,
// whether seq is empty or not; for n > 0, (empty ##n seq) is (##(n-1) seq)
// and (seq ##n empty) is (seq ##(n-1) 1). §16.9.2: a[*0] is the same as
// a[*0:0]. Each cover sequence starts with start, high only at the tick T1
// at 15, and goes on one tick later with the sequence under test; b is high
// at T2 and T3 (25, 35). So empty ##1 b and b ##1 empty end at T2, empty ##2
// b and b ##2 empty at T3, start ##1 a[*0] ##1 b is start ##1 b and ends at
// T2, and the ##0 forms never end. A cover sequence runs its statement once
// for each match, in the time step where the match ends (§16.14.3); each
// statement adds that time to the list of its cover, printed at the end.
// [*0] is not supported by Verilator 5.052.

`timescale 1ns/1ns

module test_sequence_empty_match_fusion;
  logic clk = 0, start = 0, a = 0, b = 0;
  string m[string];

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_l0: cover sequence (@(posedge clk) start ##1 (a[*0] ##0 b)) hit("empty ##0 b");
  c_r0: cover sequence (@(posedge clk) start ##1 (b ##0 a[*0])) hit("b ##0 empty");
  c_e0: cover sequence (@(posedge clk) start ##1 (a[*0] ##0 b[*0])) hit("empty ##0 empty");
  c_l1: cover sequence (@(posedge clk) start ##1 (a[*0] ##1 b)) hit("empty ##1 b");
  c_r1: cover sequence (@(posedge clk) start ##1 (b ##1 a[*0])) hit("b ##1 empty");
  c_l2: cover sequence (@(posedge clk) start ##1 (a[*0] ##2 b)) hit("empty ##2 b");
  c_r2: cover sequence (@(posedge clk) start ##1 (b ##2 a[*0])) hit("b ##2 empty");
  c_z: cover sequence (@(posedge clk) start ##1 a[*0] ##1 b) hit("a[*0]");
  c_zr: cover sequence (@(posedge clk) start ##1 a[*0:0] ##1 b) hit("a[*0:0]");

  initial begin
    @(negedge clk) start = 1;           // T1
    @(negedge clk) start = 0; b = 1;    // T2
    @(negedge clk) b = 1;               // T3
    @(negedge clk) b = 0;
    #30;
    $display("empty ##0 b: [%s ] b ##0 empty: [%s ] empty ##0 empty: [%s ]",
             ends("empty ##0 b"), ends("b ##0 empty"), ends("empty ##0 empty"));
    $display("empty ##1 b: [%s ] b ##1 empty: [%s ]", ends("empty ##1 b"), ends("b ##1 empty"));
    $display("empty ##2 b: [%s ] b ##2 empty: [%s ]", ends("empty ##2 b"), ends("b ##2 empty"));
    $display("a[*0]: [%s ] a[*0:0]: [%s ]", ends("a[*0]"), ends("a[*0:0]"));
    $finish;
  end
endmodule
