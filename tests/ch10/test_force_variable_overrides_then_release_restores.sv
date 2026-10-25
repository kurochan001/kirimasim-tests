/*
:name: test_force_variable_overrides_then_release_restores
:description: a force on a variable overrides procedural assignments, a continuous assignment and an assign procedural continuous assignment; a release gives the continuous and the procedural continuous assignment back, reevaluated, while a procedurally written variable keeps the forced value (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_variable_overrides_then_release_restores.expected
*/
// IEEE 1800-2023 §10.6.2: a force on a variable overrides a procedural
// assignment, a continuous assignment and an assign procedural continuous
// assignment to it until the variable is released. Releasing a variable
// that is driven by a continuous assignment, or that has an active assign
// procedural continuous assignment, reestablishes that assignment and
// schedules its reevaluation in the region of continuous assignments, the
// Active region; a #0 lets that reevaluation happen before the values are
// printed. A variable without such a driver keeps its value after the
// release until it is next assigned.
//
// vp is written procedurally, vc by "assign vc = src;" and va by the
// procedural "assign va = src2;". All three are forced to 55. While forced,
// vp is assigned 7 and src and src2 change, and the three stay 55. After the
// release, vc and va show src and src2 again and follow their later
// changes, while vp keeps 55 until it is assigned 9.

module test_force_variable_overrides_then_release_restores;
  int vp = 0, vc, va, src = 1, src2 = 2;

  assign vc = src;

  initial begin
    #1 assign va = src2;
    #1 $display("before force: vp=%0d vc=%0d va=%0d", vp, vc, va);
    force vp = 55;
    force vc = 55;
    force va = 55;
    #1 $display("forced:       vp=%0d vc=%0d va=%0d", vp, vc, va);
    vp = 7;
    src = 3;
    src2 = 4;
    #1 $display("writes:       vp=%0d vc=%0d va=%0d", vp, vc, va);
    release vp;
    release vc;
    release va;
    #0 $display("released:     vp=%0d vc=%0d va=%0d", vp, vc, va);
    src = 5;
    src2 = 6;
    #1 $display("new sources:  vp=%0d vc=%0d va=%0d", vp, vc, va);
    vp = 9;
    #1 $display("vp written:   vp=%0d vc=%0d va=%0d", vp, vc, va);
  end
endmodule
