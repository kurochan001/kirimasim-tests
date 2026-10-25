/*
:name: test_illegal_bind_module_into_interface
:description: A bind whose target is an interface can only instantiate an interface or a checker, not a module (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second bind statement instantiates the module bmi_mon into the interface bmi_bus
:expected_stderr_regex: test_illegal_bind_module_into_interface\.sv:37:
*/
// IEEE 1800-2023 §23.11: when the target scope or target instance of a bind
// is an interface, the bound instantiation shall be an interface or checker
// instantiation (footnote 4 of Syntax 23-9). Binding the interface
// bmi_watch into bmi_bus is legal; binding the module bmi_mon into it is not.
// Both instantiations connect the member s of bmi_bus, which is visible from
// the target's point of view.
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator accepts the design.

interface bmi_bus;
  logic s = 1'b1;
endinterface

interface bmi_watch(input logic s);
endinterface

module bmi_mon(input logic s);
endmodule

module test_illegal_bind_module_into_interface;
  bmi_bus bus ();
  bind bmi_bus bmi_watch w (.s(s));
  bind bmi_bus bmi_mon m (.s(s));   // illegal: a module bound into an interface
endmodule
