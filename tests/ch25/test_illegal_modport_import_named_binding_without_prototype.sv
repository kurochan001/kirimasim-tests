/*
:name: test_illegal_modport_import_named_binding_without_prototype
:description: A call through a modport that binds arguments by name needs the modport to import the subroutine with a full prototype (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module mnb_name calls set with arguments bound by name through the modport bad, which imports set by name only
:expected_stderr_regex: test_illegal_modport_import_named_binding_without_prototype\.sv:(29|37):
*/
// IEEE 1800-2023 §25.7: when argument binding by name is used, a modport shall
// import the subroutine with a full prototype. The modport good imports the
// task set of mnb_bus with its prototype, so mnb_proto can call it with
// .a(1), .b(3); the modport bad imports set by name only, and mnb_name makes
// the same call through it. Calls by position through bad would be legal.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and stops with a syntax error at the header of mnb_proto; the 5.052 release
// of Verilator accepts the design.

interface mnb_bus;
  int r;
  task set(input int a, input int b);
    r = a * 10 + b;
  endtask
  modport good (import task set(input int a, input int b));
  modport bad (import set);   // the error can also be reported here
endinterface

module mnb_proto(mnb_bus.good p);
  initial p.set(.a(1), .b(3));
endmodule

module mnb_name(mnb_bus.bad p);
  initial #1 p.set(.a(2), .b(4));   // illegal: binding by name without a prototype
endmodule

module test_illegal_modport_import_named_binding_without_prototype;
  mnb_bus bus ();
  mnb_proto u1 (bus);
  mnb_name u2 (bus);
endmodule
