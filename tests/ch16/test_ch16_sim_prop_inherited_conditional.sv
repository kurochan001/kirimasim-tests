/*
:name: test_ch16_sim_prop_inherited_conditional
:description: an if property under an outer clock takes its branch from the condition and its operand values at the outer clock ticks, so values that exist only between ticks do not change the branch (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.12.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_ch16_sim_prop_inherited_conditional.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of
// if (b) q is {inherited}, so under the explicit clock c the property is
// evaluated at the ticks of c and its expressions are sampled there.
// The clock rises at 5, 15, 25 and 35. g and a are 1 at the tick at 5, so
// the then branch passes. g becomes 0 at 7, between ticks, where a is 1 and
// b is 0; that is not used. At 15 the sampled g is 0 and b is 0, so the else
// branch fails. At 25 the sampled g is 1 and a is 1, so the then branch
// passes. a becomes 0 at 27, between ticks; at 35 the sampled g is 1 and a is
// 0, so the then branch fails. The failure queue holds 15 and 35 only.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_prop_inherited_conditional;
  logic clk = 0;
  logic g = 0;
  logic a = 0;
  logic b = 0;
  int fails[$];

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) if (g) a else b)
    else fails.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0t", q[i])};
    return s;
  endfunction

  initial begin
    g = 1;
    a = 1;
    b = 1;
    #7 g = 0;
    b = 0;
    #13 g = 1;
    #7 a = 0;
    #13;
    $display("if fails at:%s", times(fails));
    $finish;
  end
endmodule
