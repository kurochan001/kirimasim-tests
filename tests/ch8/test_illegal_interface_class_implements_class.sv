/*
:name: test_illegal_interface_class_implements_class
:description: an interface class cannot implement a class or virtual class (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class bad_if implements the virtual class shape_vc
:expected_stderr_regex: test_illegal_interface_class_implements_class\.sv:35:
*/
// IEEE 1800-2023 §8.26.2: an interface class may extend interface classes,
// but it may not implement a class or virtual class, nor an interface class.
// both_if extends two interface classes, which is legal; bad_if implements
// the virtual class shape_vc.
// Icarus Verilog 13.0 does not support interface classes.

interface class a_if;
  pure virtual function int fa();
endclass

interface class b_if;
  pure virtual function int fb();
endclass

virtual class shape_vc;
  pure virtual function int fa();
endclass

interface class both_if extends a_if, b_if;
endclass

interface class bad_if implements shape_vc;   // illegal: implements a virtual class
endclass

module test_illegal_interface_class_implements_class;
  initial $display("done");
endmodule
