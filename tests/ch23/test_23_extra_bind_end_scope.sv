/*
:name: test_23_extra_bind_end_scope
:description: An instance bound into a target scope sees the target's declarations and the wildcard-import candidates already imported there (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_bind_end_scope.expected
*/
// IEEE 1800-2023 §23.11: when an instance is bound into a target scope, the
// effect is as if the instance were present at the very end of the target
// scope. All declarations present in the target scope or imported into it
// are visible to the bound instance, and wildcard import candidates that
// have been imported into the scope are visible.
// The target bes_target declares lvar, whose value 7 comes from the
// package member pv, which the wildcard import makes a candidate. Because
// the target itself uses pv in the initializer of lvar, pv is already an
// imported candidate when the bound instance sees it. The bound probe reads
// lvar and pv from the target's point of view, so their values are 7 and 6.
// The clause also says that a bind statement cannot cause the import of a
// wildcard candidate and that unit declarations and imports are not
// visible; those are negative cases and are not exercised here.
// The 5.052 release of Verilator produces this output; Icarus Verilog 13.0
// has no bind directive.

package bes_pkg;
  int pv = 6;
endpackage

module bes_bt(input int a);
endmodule

module bes_target;
  import bes_pkg::*;
  int lvar = pv + 1;
  bes_bt u(lvar);
endmodule

module bes_probe(input int x, input int y);
  initial #1 $display("x=%0d y=%0d", x, y);
endmodule

bind bes_target bes_probe p(.x(lvar), .y(pv));

module test_23_extra_bind_end_scope;
  bes_target t();

  initial #2 $finish;
endmodule
