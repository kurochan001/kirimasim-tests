/*
:name: test_illegal_type_this_outside_class
:description: type(this) cannot be used outside a class (IEEE 1800-2023 Section 8.11)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.11 6.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: type(this) is used in a module, outside any class
:expected_stderr_regex: test_illegal_type_this_outside_class\.sv:22:
*/
// IEEE 1800-2023 §8.11: this shall only be used as type(this) or within
// non-static class methods, constraints and covergroups of classes, and §6.23
// defines type(this) as the type of the enclosing class; a module has none, so
// an error shall be issued.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so the
// error it reports on that line does not count.

module test_illegal_type_this_outside_class;
  var type(this) handle;   // illegal: no enclosing class
  initial $display("done");
endmodule
