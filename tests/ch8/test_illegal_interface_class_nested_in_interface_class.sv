/*
:name: test_illegal_interface_class_nested_in_interface_class
:description: an interface class cannot be nested in another interface class (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class inner_if is declared inside the interface class outer_if
:expected_stderr_regex: test_illegal_interface_class_nested_in_interface_class\.sv:22:
*/
// IEEE 1800-2023 §8.26: an interface class shall not be nested within another
// interface class. An interface class can instead extend another one:
// child_if extends outer_if, which is legal; inner_if is declared inside
// outer_if.
// Icarus Verilog 13.0 does not support interface classes.

interface class outer_if;
  pure virtual function int size();
  interface class inner_if;   // illegal: interface class inside an interface class
    pure virtual function int depth();
  endclass
endclass

interface class child_if extends outer_if;
  pure virtual function int depth();
endclass

module test_illegal_interface_class_nested_in_interface_class;
  initial $display("done");
endmodule
