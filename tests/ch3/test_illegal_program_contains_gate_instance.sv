/*
:name: test_illegal_program_contains_gate_instance
:description: A program that contains an instance of a built-in gate primitive is rejected (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.4 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program contains a primitive instance, which a program cannot contain
:expected_stderr_regex: test_illegal_program_contains_gate_instance\.sv:26:
*/
// IEEE 1800-2023 §3.4: a program cannot contain primitive instances (nor
// always procedures or module, interface or program instances); §24.3 states
// the same. The program below declares a variable and a net, which a program
// may do, and an initial procedure; the and gate instance on the marked line
// is the only item that a program cannot contain. The module instantiates the
// program and connects its ports.

program test_illegal_program_contains_gate_instance_p(input logic a, input logic b);
  logic y_reg = 1'b0;
  wire y_gate;

  initial #1 $display("y_reg=%b", y_reg);
  and g_and(y_gate, a, b);   // illegal: primitive instance in a program
endprogram

module test_illegal_program_contains_gate_instance;
  logic a = 1'b1, b = 1'b0;
  test_illegal_program_contains_gate_instance_p p(.a(a), .b(b));
endmodule
