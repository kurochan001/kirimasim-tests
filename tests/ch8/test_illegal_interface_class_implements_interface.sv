/*
:name: test_illegal_interface_class_implements_interface
:description: an interface class can extend interface classes but cannot implement one (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class bad_if implements the interface class a_if
:expected_stderr_regex: test_illegal_interface_class_implements_interface\.sv:32:
*/
// IEEE 1800-2023 §8.26.2: an interface class may extend zero or more
// interface classes, but it may not implement an interface class, nor
// extend or implement a class or virtual class. both_if extends two
// interface classes, which is legal; bad_if implements one.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

interface class a_if;
  pure virtual function int fa();
endclass

interface class b_if;
  pure virtual function int fb();
endclass

interface class both_if extends a_if, b_if;
endclass

interface class bad_if implements a_if;   // illegal: implements in an interface class
endclass

module test_illegal_interface_class_implements_interface;
  initial $display("done");
endmodule
