/*
:name: test_illegal_interface_class_covergroup
:description: A covergroup cannot be declared in an interface class (IEEE 1800-2023 Section 8.26.9)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class cov_if declares a covergroup
:expected_stderr_regex: test_illegal_interface_class_covergroup\.sv:(21|23):
*/
// IEEE 1800-2023 §8.26.9: constraint blocks and covergroups shall not be
// declared in interface classes. cov_if declares the covergroup cg. A tool
// can report the covergroup or the interface class that holds it. Icarus
// Verilog 13.0 does not support interface classes, so the syntax errors it
// reports do not count.

module test_illegal_interface_class_covergroup;
  interface class cov_if;
    pure virtual function int value();
    covergroup cg;   // illegal: a covergroup in an interface class
    endgroup
  endclass
endmodule
