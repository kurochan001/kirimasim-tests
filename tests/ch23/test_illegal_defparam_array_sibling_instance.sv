/*
:name: test_illegal_defparam_array_sibling_instance
:description: A defparam statement in one instance of an array of instances cannot change a parameter in another instance of the same array (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.1 23.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam in the element arr[0] names the parameter of the instance l inside the element arr[1]
:expected_stderr_regex: test_illegal_defparam_array_sibling_instance\.sv:30:
*/
// IEEE 1800-2023 §23.10.1: each instance of an array of instances is a
// hierarchy of its own, so a defparam statement in one element may not
// target a parameter in another element of the same array. Every element
// of arr holds the defparam of its module, which names arr[1].l.P from the
// top module; for the element arr[0], that is the instance l of its
// sibling arr[1].
// Icarus Verilog 13.0 accepts this design. Verilator 5.052 rejects it at the
// defparam only because it does not support a defparam that names an
// element of an array, so it is not listed as an oracle.

module defparam_array_sibling_leaf;
  parameter int P = 0;
endmodule

module defparam_array_sibling_elem;
  defparam_array_sibling_leaf l();
  defparam test_illegal_defparam_array_sibling_instance.arr[1].l.P = 5;   // illegal
endmodule

module test_illegal_defparam_array_sibling_instance;
  defparam_array_sibling_elem arr[1:0] ();
endmodule
