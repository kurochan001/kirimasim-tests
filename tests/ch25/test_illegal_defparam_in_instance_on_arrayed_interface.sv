/*
:name: test_illegal_defparam_in_instance_on_arrayed_interface
:description: A defparam inside an instance whose interface port actual is an element of an interface array cannot change a parameter outside that instance (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u, whose port b is connected to buses[0] of the interface array buses, has a defparam that changes the parameter of the interface solo outside u
:expected_stderr_regex: test_illegal_defparam_in_instance_on_arrayed_interface\.sv:34:
*/
// IEEE 1800-2023 §25.3: a defparam within an instance whose port actuals
// refer to an arrayed interface shall not modify a parameter outside the
// hierarchy of that instance. The module dai_user is instantiated as u with
// the element buses[0] of an interface array. Its first defparam changes
// the parameter of its own instance inner, which is legal; the second
// changes the parameter of the interface solo of the top module.
// Oracle checks: Icarus Verilog 13.0 does not support interface ports and stops
// at the header of a module that has one; the 5.052 release of Verilator
// accepts the design.

interface dai_if #(parameter int W = 1);
  logic [W-1:0] s;
endinterface

module dai_leaf #(parameter int P = 1) ();
endmodule

module dai_user(dai_if b);
  dai_leaf inner ();
  defparam inner.P = 3;
  defparam test_illegal_defparam_in_instance_on_arrayed_interface.solo.W = 4;   // illegal
endmodule

module test_illegal_defparam_in_instance_on_arrayed_interface;
  dai_if buses [1:0] ();
  dai_if solo ();
  dai_user u (.b(buses[0]));
endmodule
