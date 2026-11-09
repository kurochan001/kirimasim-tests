/*
:name: test_ref_static_force_release
:description: force and release, procedural continuous assignments that may not write automatic variables, can act on the variable that a ref static argument refers to, even after the task returns (IEEE 1800-2023 Sections 13.5.2, 6.21, 10.6.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 6.21 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_static_force_release.expected
*/
// IEEE 1800-2023 §6.21: automatic variables shall not be written by
// procedural continuous assignments; §13.5.2: a ref argument shall not be
// used where an automatic variable may not, unless it is ref static. So the
// tasks hold and free can force and release the variable that their ref
// static argument refers to, here v.
// §10.6.2: while v is forced, it takes the value of the force expression
// src + 1 and follows src, and procedural assignments to it have no effect;
// after release it keeps its value until the next procedural assignment.
// So v is 5 (src 4 + 1) after hold, stays 5 after v = 9, becomes 7 when src
// becomes 6, stays 7 after free, and becomes 1 after v = 1. The force stays
// in effect after hold returns.
// The expected output follows the standard alone: Icarus Verilog 13.0 does
// not support ref arguments, and the 5.052 release of Verilator does not
// support ref static ones.

module test_ref_static_force_release;
  int v;
  int src;

  task automatic hold(ref static int r);
    force r = src + 1;
  endtask

  task automatic free(ref static int r);
    release r;
  endtask

  initial begin
    v = 0;
    src = 4;
    hold(v);
    #1 $display("forced: %0d", v);
    v = 9;
    #1 $display("assigned while forced: %0d", v);
    src = 6;
    #1 $display("source changed: %0d", v);
    free(v);
    #1 $display("released: %0d", v);
    v = 1;
    #1 $display("assigned after release: %0d", v);
  end
endmodule
