/*
:name: test_assertion_kinds_checked_covered_restricted
:description: assert and assume properties are checked, cover counts matches, restrict is not checked, and immediate and concurrent assertions see current and sampled values (IEEE 1800-2023 Section 16.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.2 16.3 16.5.1 16.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stderr_regex: \A(?![\s\S]*test_assertion_kinds_checked_covered_restricted\.sv:42\b)
:expected_stdout: @test_assertion_kinds_checked_covered_restricted.expected
*/
// IEEE 1800-2023 §16.2: an assert statement states a property that is checked,
// an assume statement one that simulators also check, a cover statement one
// whose evaluation is monitored for coverage, and a restrict statement one that
// simulators do not check. Immediate assertions execute like procedural
// statements and see the current values (16.3); concurrent assertions are
// evaluated at their clock with the sampled values (16.5.1).
// a is 1 at the clock events at 5 and 25 and 0 at 15. p_assert and p_assume
// count their passes and failures in their action blocks, p_cover counts its
// matches, and p_restrict, which fails at 15 as well, has no action block, so a
// check would report it by the default action; the messages of the run must
// not name its line. At 5 the initial procedure, resumed by the same clock
// event, sets b to 1 between two immediate assertions, which both pass, while
// p_sampled, evaluated with the value of b sampled before the event, fails
// there and passes at 15 and 25.
// Icarus Verilog 13.0 does not support concurrent assertions.

`timescale 1ns/1ns
module test_assertion_kinds_checked_covered_restricted;
  logic clk = 0, a = 1, b = 0;
  int ap, af, af_t, mp, mf, mf_t, cp, sp, sf, sf_t, i_before, i_after;

  always #5 clk = ~clk;

  p_assert: assert property (@(posedge clk) a) ap++;
            else begin af++; af_t = $time; end
  p_assume: assume property (@(posedge clk) a) mp++;
            else begin mf++; mf_t = $time; end
  p_cover: cover property (@(posedge clk) a) cp++;
  p_restrict: restrict property (@(posedge clk) a);
  p_sampled: assert property (@(posedge clk) b) sp++;
             else begin sf++; sf_t = $time; end

  initial begin
    #10 a = 0;
    #10 a = 1;
  end

  initial begin
    @(posedge clk);
    i_b: assert (b == 0) i_before++;
    b = 1;
    i_a: assert (b == 1) i_after++;
  end

  initial begin
    #32;
    $display("assert pass=%0d fail=%0d at %0d", ap, af, af_t);
    $display("assume pass=%0d fail=%0d at %0d", mp, mf, mf_t);
    $display("cover matches=%0d", cp);
    $display("immediate before=%0d after=%0d", i_before, i_after);
    $display("sampled pass=%0d fail=%0d at %0d", sp, sf, sf_t);
    $finish;
  end
endmodule
