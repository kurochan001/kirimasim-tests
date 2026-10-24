/*
:name: test_illegal_modport_export_task_prototype_mismatch
:description: A subroutine that a module defines for an exported prototype of a modport has to match that prototype exactly (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the task put of mxp_bad has an argument of type logic [7:0], where the exported prototype has int
:expected_stderr_regex: test_illegal_modport_export_task_prototype_mismatch\.sv:(37|45):
*/
// IEEE 1800-2023 §25.7: if a modport contains an exported subroutine prototype
// and the subroutine defined in the connected module does not exactly match
// that prototype, an elaboration error occurs. The modport tgt exports the
// prototype task put(input int v). mxp_ok defines put with that signature;
// mxp_bad defines it with an argument of type logic [7:0].
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces or subroutines in modports, and its syntax errors, which also fall
// on the lines named here, are not counted; the 5.052 release of Verilator
// reports the extern task as unsupported.

interface mxp_bus;
  int r;
  extern task put(input int v);
  modport tgt (export task put(input int v));
endinterface

module mxp_ok(mxp_bus.tgt b);
  task b.put(input int v);
    b.r = v;
  endtask
endmodule

module mxp_bad(mxp_bus.tgt b);
  task b.put(input logic [7:0] v);   // illegal: does not match the prototype
    b.r = v;
  endtask
endmodule

module test_illegal_modport_export_task_prototype_mismatch;
  mxp_bus bus1 (), bus2 ();
  mxp_ok ok (bus1);
  mxp_bad u (bus2);   // the error can also be reported here
endmodule
