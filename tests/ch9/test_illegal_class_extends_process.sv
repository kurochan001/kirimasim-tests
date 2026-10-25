/*
:name: test_illegal_class_extends_process
:description: the built-in class process cannot be extended (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class my_proc_c extends the built-in class process
:expected_stderr_regex: test_illegal_class_extends_process\.sv:21:
*/
// IEEE 1800-2023 §9.7: process is a built-in class; a handle of it can be
// declared and passed around, as the initial procedure does with
// process::self(), but the process class cannot be extended, and an attempt
// to extend it shall be a compilation error.
// Icarus Verilog 13.0 does not support the process class, so its syntax error
// on the line of the error does not count; Verilator 5.052 accepts the design.

class my_proc_c extends process;   // illegal: process cannot be extended
endclass

module test_illegal_class_extends_process;
  process p;
  initial begin
    p = process::self();
    $display("%0d", p != null);
  end
endmodule
