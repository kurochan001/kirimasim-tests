/*
:name: test_illegal_modport_import_default_argument_without_prototype
:description: A call through a modport that relies on a default argument value needs the modport to import the subroutine with a full prototype that gives the default (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module mid_name calls add with one argument, relying on the default of b, through the modport bad, which imports add by name only
:expected_stderr_regex: test_illegal_modport_import_default_argument_without_prototype\.sv:(30|38):
*/
// IEEE 1800-2023 §25.7: when default argument values are used, a modport
// shall import the subroutine with a full prototype, and a default needed in
// a call shall be specified in the prototype. The task add of mid_bus has
// the default b = 2. The modport good imports add with a prototype that
// gives the default, so mid_proto can call add(1); the modport bad imports
// add by name only, and mid_name makes the same call through it.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and stops with a syntax error at the header of mid_proto; the 5.052 release
// of Verilator accepts the design.

interface mid_bus;
  int r;
  task add(input int a, input int b = 2);
    r = a + b;
  endtask
  modport good (import task add(input int a, input int b = 2));
  modport bad (import add);   // the error can also be reported here
endinterface

module mid_proto(mid_bus.good p);
  initial p.add(1);
endmodule

module mid_name(mid_bus.bad p);
  initial #1 p.add(1);   // illegal: the default of b is not in a prototype
endmodule

module test_illegal_modport_import_default_argument_without_prototype;
  mid_bus bus ();
  mid_proto u1 (bus);
  mid_name u2 (bus);
endmodule
