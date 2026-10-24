/*
:name: test_illegal_modport_export_task_not_defined
:description: A module connected to a modport that exports a subroutine has to define that subroutine (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module mxd_partial is connected to the modport tgt, which exports get, and defines only put
:expected_stderr_regex: test_illegal_modport_export_task_not_defined\.sv:(40|49):
*/
// IEEE 1800-2023 §25.7: if a module is connected to a modport containing an
// exported subroutine and the module does not define that subroutine, an
// elaboration error occurs. The modport tgt exports put and get. mxd_full
// defines both and its instance ok is legal; mxd_partial defines only put,
// and its instance u leaves get undefined.
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces or subroutines in modports, and its syntax errors, which also fall
// on the lines named here, are not counted; the 5.052 release of Verilator
// reports the extern tasks as unsupported.

interface mxd_bus;
  int r;
  extern task put(input int v);
  extern task get(output int v);
  modport tgt (export put, export get);
endinterface

module mxd_full(mxd_bus.tgt b);
  task b.put(input int v);
    b.r = v;
  endtask
  task b.get(output int v);
    v = b.r;
  endtask
endmodule

module mxd_partial(mxd_bus.tgt b);   // the error can also be reported here
  task b.put(input int v);
    b.r = v;
  endtask
endmodule

module test_illegal_modport_export_task_not_defined;
  mxd_bus bus1 (), bus2 ();
  mxd_full ok (bus1);
  mxd_partial u (bus2);   // illegal: u does not define get
endmodule
