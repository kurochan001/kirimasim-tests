/*
:name: test_checker_assertion_sampling_as_module
:description: A concurrent assertion in a checker samples its operands and runs its action blocks exactly like the same assertion in a module, although the procedures of a checker run in the Reactive region (IEEE 1800-2023 Section 17.7.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.3 16.5.1 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assertion_sampling_as_module.expected
*/
// IEEE 1800-2023 §17.7.3: concurrent assertions have the same scheduling
// semantics in a checker as in design code. §16.5.1: the operands of a
// concurrent assertion are sampled in the Preponed region, and the action
// block runs in the same time step after the evaluation (§16.14.1).
// The module and the checker each assert d at the rising edges of clk at
// 10, 20, 30 and 40. d changes in the same time step as the edges at 10,
// 20 and 40, so the sampled values at the four edges are 0, 1, 0, 0: the
// assertions fail, pass, fail, fail, both in the checker and in the
// module. An assertion that read the current value of d after the edge,
// as the checker procedures of §17.7.3 do, would give pass, fail, fail,
// pass. The checker prints from its action blocks, one line per edge; the
// module collects its results in a string that is printed at the end, so
// no two lines are printed in the same time step.
// Icarus Verilog 13.0 does not compile checkers.

`timescale 1ns/1ns

checker cas_chk(logic clk, logic d);
  a_chk: assert property (@(posedge clk) d)
    $display("checker: pass at %0t", $time);
  else
    $display("checker: fail at %0t", $time);
endchecker

module test_checker_assertion_sampling_as_module;
  bit clk = 0, d = 0;
  string mod_log = "";

  a_mod: assert property (@(posedge clk) d)
    mod_log = {mod_log, $sformatf(" pass@%0t", $time)};
  else
    mod_log = {mod_log, $sformatf(" fail@%0t", $time)};

  cas_chk c(clk, d);

  initial begin
    #10 clk = 1; d = 1;
    #5  clk = 0;
    #5  clk = 1; d = 0;
    #5  clk = 0;
    #5  clk = 1;
    #5  clk = 0;
    #5  clk = 1; d = 1;
    #5  clk = 0;
    #1  $display("module:%s", mod_log);
    $finish;
  end
endmodule
