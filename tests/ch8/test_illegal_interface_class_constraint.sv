/*
:name: test_illegal_interface_class_constraint
:description: An interface class cannot declare a constraint block (IEEE 1800-2023 Section 8.26.9)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class declares a constraint block
:expected_stderr_regex: test_illegal_interface_class_constraint\.sv:(21|23):
*/
// IEEE 1800-2023 §8.26.9: constraint blocks and covergroups shall not be
// declared in interface classes, which hold no data either. A tool can report
// the constraint or the interface class that holds it. Icarus Verilog 13.0 does
// not support interface classes, so the syntax errors it reports there, as on
// most other lines, do not count.

module test_illegal_interface_class_constraint;
  interface class limit_if;   // illegal: the class holds a constraint
    pure virtual function int bound();
    constraint tiny_c { 1 < 2; }   // illegal: a constraint in an interface class
  endclass
endmodule
