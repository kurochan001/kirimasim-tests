/*
:name: test_ch16_sim_prop_inherited_case
:description: a case property under an outer clock selects its branch from the value of the case expression at the outer clock ticks, so a value that exists only between ticks does not select a branch (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.12.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_prop_inherited_case.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of
// case (b) b1: q1 ... endcase is {inherited}, so under the explicit clock c
// the property is evaluated at the ticks of c and b is sampled there.
// The clock rises at 5, 15, 25 and 35. At 5 the sampled s is 2 and the branch
// b is 1, so the attempt passes. s becomes 1 at 7, between ticks, where a is
// 0; that value is not used. At 15 the sampled s is 2 again but b is 0, so
// the branch fails. At 25 the sampled s is 1 and a is 1, and at 35 s is 2 and
// b is 1, so both pass. The failure queue holds 15 only.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_prop_inherited_case;
  logic clk = 0;
  logic a = 0;
  logic b = 0;
  int s = 0;
  int fails[$];

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) case (s)
    1: a;
    2: b;
    default: 1'b1;
  endcase) else fails.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0t", q[i])};
    return s;
  endfunction

  initial begin
    s = 2;
    b = 1;
    #7 s = 1;
    #3 s = 2;
    b = 0;
    #10 s = 1;
    a = 1;
    #10 s = 2;
    b = 1;
    #10;
    $display("case fails at:%s", times(fails));
    $finish;
  end
endmodule
