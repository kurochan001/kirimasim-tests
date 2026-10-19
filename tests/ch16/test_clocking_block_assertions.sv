/*
:name: test_clocking_block_assertions
:description: a property declared in a clocking block is clocked by its clocking event, and a clocking block input used in a concurrent assertion is sampled only by the clocking block, with its input skew, not again by the assertion (IEEE 1800-2023 Section 16.18)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.18 14.3 14.4 16.5.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_block_assertions.expected
*/
// IEEE 1800-2023 §16.18: a clocking block variable used in a concurrent
// assertion is sampled only in the clocking block. With the default input
// skew (#1step, §14.4) that is the same value as the assertion's own sample
// (§16.5.1), so the assertions on a, on the property p declared in cb_in or in
// cb_none, and on cb_in.a fail at the same ticks. With an input skew of #2
// (§14.3), cb_skew.a is the value of a 2 before the edge: a rises 1 before
// the edge at 15 and falls 1 before the edge at 35, which the other
// assertions see at those edges but cb_skew.a sees only one edge later. The
// fail actions (§16.14.1) record the failure times.

`timescale 1ns/1ns

module test_clocking_block_assertions;
  logic clk = 0, a = 0;
  int f_plain[$], f_in_p[$], f_none_p[$], f_cbvar[$], f_skew[$];

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, 35, 45

  clocking cb_in @(posedge clk);
    input a;
    property p;
      a;
    endproperty
  endclocking

  clocking cb_none @(posedge clk);
    property p;
      a;
    endproperty
  endclocking

  clocking cb_skew @(posedge clk);
    input #2 a;
  endclocking

  a_plain: assert property (@(posedge clk) a) else f_plain.push_back($time);
  a_in_p: assert property (cb_in.p) else f_in_p.push_back($time);
  a_none_p: assert property (cb_none.p) else f_none_p.push_back($time);
  a_cbvar: assert property (@(posedge clk) cb_in.a) else f_cbvar.push_back($time);
  a_skew: assert property (@(posedge clk) cb_skew.a) else f_skew.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #14 a = 1;   // 1 before the edge at 15
    #20 a = 0;   // 34: 1 before the edge at 35
    #16;
    $display("a:%s", times(f_plain));
    $display("cb_in.p:%s", times(f_in_p));
    $display("cb_none.p:%s", times(f_none_p));
    $display("cb_in.a:%s", times(f_cbvar));
    $display("cb_skew.a:%s", times(f_skew));
    $finish;
  end
endmodule
