/*
:name: test_implicit_always_attempts
:description: a concurrent assertion outside an initial procedure starts an evaluation attempt at every tick of its leading clock, the same as one attempt of always p started at the first tick from an initial procedure, while the same assertion in an initial procedure is attempted only once (IEEE 1800-2023 Section 16.12.11)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.11 16.14.6 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_always_attempts.expected
*/
// IEEE 1800-2023 §16.12.11: a verification statement that is not in an
// initial procedure begins an evaluation attempt of its property at each
// occurrence of its leading clocking event (the implicit always), which
// matches one attempt of always p started at the first tick; always p fails
// at the first tick where p fails. §16.14.6: an assertion in an initial
// procedure is queued when reached at time 0 and begins one attempt at the
// next tick of its clock. x is high at the ticks at 5, 15, 35 and 55 and low
// at 25 and 45. a_static is a module item: it passes at 5, 15, 35 and 55 and
// fails at 25 and 45. a_once, in an initial procedure, is attempted only at
// 5, where it passes. a_always, always x in an initial procedure, fails at
// 25, its first tick without x, and its attempt then ends. The actions
// (§16.14.1) record the times; the lists are printed at the end.

`timescale 1ns/1ns

module test_implicit_always_attempts;
  logic clk = 0, x = 0;
  int p_static[$], f_static[$], p_once[$], f_once[$], p_always[$], f_always[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_static: assert property (@(posedge clk) x) p_static.push_back($time);
    else f_static.push_back($time);

  initial begin
    a_once: assert property (@(posedge clk) x) p_once.push_back($time);
      else f_once.push_back($time);
  end

  initial begin
    a_always: assert property (@(posedge clk) always x) p_always.push_back($time);
      else f_always.push_back($time);
  end

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  initial begin
    logic [0:5] xs;
    xs = 6'b110101;   // x at the ticks at 5, 15, 25, 35, 45 and 55
    foreach (xs[i]) begin
      x = xs[i];
      #10;
    end
    $display("a_static: passes%s, failures%s", times(p_static), times(f_static));
    $display("a_once: passes%s, failures%s", times(p_once), times(f_once));
    $display("a_always: passes%s, failures%s", times(p_always), times(f_always));
    $finish;
  end
endmodule
