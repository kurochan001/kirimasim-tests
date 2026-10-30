/*
:name: test_ch16_sim_prop_inherited_always
:description: always a under an outer clock is evaluated only at the outer clock ticks, so a drop of a between ticks is not seen and the attempts fail only at the tick whose sample is false (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.12.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_prop_inherited_always.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of always q is
// {inherited}, so under the explicit clock c the property always a is
// evaluated at the ticks of c and a is sampled there. The clock rises at 5,
// 15, 25 and 35. a is 1 at the ticks at 5 and 15. It drops to 0 at 7, between
// ticks, which is not seen, and is 1 again at 10. It drops to 0 at 22, so the
// tick at 25 samples it as 0. §16.12.11: an assertion outside a procedure
// begins an evaluation attempt of always a at every tick, so the attempts
// from 5, 15 and 25 are all running at 25 and each of them fails there, while
// the tick at 35 samples 1 again and the attempt from 35 is still pending at
// the end. The failure queue therefore holds 25 three times. It is printed at
// the end, so the order of the three fail actions at 25 does not matter.
// Icarus Verilog 13.0 has no concurrent assertions, and Verilator 5.052
// reports a single failure at 25 (docs/simulator-differences.md), so the
// expected output comes from the standard alone.

`timescale 1ns/1ns

module test_ch16_sim_prop_inherited_always;
  logic clk = 0;
  logic a = 1;
  int fails[$];

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) always a) else fails.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0t", q[i])};
    return s;
  endfunction

  initial begin
    #7 a = 0;
    #3 a = 1;
    #12 a = 0;
    #5 a = 1;
    #13;
    $display("always a fails at:%s", times(fails));
    $finish;
  end
endmodule
