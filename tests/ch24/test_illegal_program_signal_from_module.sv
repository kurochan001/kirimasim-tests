/*
:name: test_illegal_program_signal_from_module
:description: A reference to a program variable from outside every program is an error (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 23.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a module refers to a variable declared in a program
:expected_stderr_regex: test_illegal_program_signal_from_module\.sv:27:
*/
// IEEE 1800-2023 §24.3: the variables and nets declared in a program are
// program signals, and references to them from outside any program block
// shall be an error; the design does not see into the testbench.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design
// (docs/simulator-differences.md).

program test_illegal_program_signal_from_module_p;
  int count = 3;
  initial #1 count++;
endprogram

module test_illegal_program_signal_from_module;
  test_illegal_program_signal_from_module_p p();
  initial #2 $display("count=%0d", p.count);   // illegal: program variable read by a module
endmodule
