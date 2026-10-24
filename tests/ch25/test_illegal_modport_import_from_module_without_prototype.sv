/*
:name: test_illegal_modport_import_from_module_without_prototype
:description: A modport that imports a subroutine defined in another module has to give its full prototype, not only its name (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the modport ini_bad imports put, which the module mip_target defines, by its name alone
:expected_stderr_regex: test_illegal_modport_import_from_module_without_prototype\.sv:(30|44):
*/
// IEEE 1800-2023 §25.7: in a modport, import and export can name a subroutine
// by its prototype or just by its identifier, except that importing a
// subroutine from another module requires the full prototype. put is
// defined in mip_target through the export of the modport tgt. The modport
// ini_ok imports it with its prototype and is legal; ini_bad imports it by
// name, and the module mip_name calls it through ini_bad.
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces or subroutines in modports, and its syntax errors, which also fall
// on the lines named here, are not counted; the 5.052 release of Verilator
// reports the extern task as unsupported.

interface mip_bus;
  int r;
  extern task put(input int v);
  modport tgt (export put);
  modport ini_ok (import task put(input int v));
  modport ini_bad (import put);   // illegal: put comes from another module
endinterface

module mip_target(mip_bus.tgt b);
  task b.put(input int v);
    b.r = v;
  endtask
endmodule

module mip_proto(mip_bus.ini_ok b);
  initial b.put(1);
endmodule

module mip_name(mip_bus.ini_bad b);
  initial #1 b.put(2);   // the error can also be reported here
endmodule

module test_illegal_modport_import_from_module_without_prototype;
  mip_bus bus ();
  mip_target t (bus);
  mip_proto p (bus);
  mip_name n (bus);
endmodule
