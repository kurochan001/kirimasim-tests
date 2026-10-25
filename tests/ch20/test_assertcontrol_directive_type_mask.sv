/*
:name: test_assertcontrol_directive_type_mask
:description: the directive_type argument of $assertcontrol selects assert (1), cover (2) and assume (4) directives, OR-ed values select several, and without it all three are selected (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.14.1 16.14.2 16.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_directive_type_mask.expected
*/
// IEEE 1800-2023 §20.11, Table 20-7: directive_type 1 selects assert, 2 cover
// and 4 assume directives; OR-ed values select several, and the default is
// 7, all three. control_type 4 (Off) stops the checking of the selected
// assertions and 3 (On) starts it again; assertion_type 1 selects the
// concurrent ones.
// x stays 0, so at every clock tick the assertion as1 and the assumption am1
// fail and the cover statement cv1 of !x succeeds (16.14.1 to 16.14.3); the
// fail actions and the pass statement of the cover count. Every phase has two
// ticks; then the counts are printed and cleared, and $assertcontrol(3)
// starts every directive again. A directive that is checked counts 2, one
// that is off counts 0. Before each phase, $assertcontrol(4, 1, d) turns off
// the directives that d selects: none, 1, 2, 4, 6 (2|4), 5 (1|4), and with
// no directive_type at all.

`timescale 1ns/1ns

module test_assertcontrol_directive_type_mask;
  logic clk = 0, x = 0;
  int as_f = 0, am_f = 0, cv_p = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  as1: assert property (@(posedge clk) x) else as_f++;
  am1: assume property (@(posedge clk) x) else am_f++;
  cv1: cover property (@(posedge clk) !x) cv_p++;

  task automatic phase(string name);
    #20 $display("%s: assert %0d, cover %0d, assume %0d", name, as_f, cv_p, am_f);
    as_f = 0;
    am_f = 0;
    cv_p = 0;
    $assertcontrol(3);
  endtask

  initial begin
    phase("none off");
    $assertcontrol(4, 1, 1);
    phase("directive 1");
    $assertcontrol(4, 1, 2);
    phase("directive 2");
    $assertcontrol(4, 1, 4);
    phase("directive 4");
    $assertcontrol(4, 1, 6);
    phase("directive 6");
    $assertcontrol(4, 1, 5);
    phase("directive 5");
    $assertcontrol(4, 1);
    phase("no directive_type");
    $finish;
  end
endmodule
