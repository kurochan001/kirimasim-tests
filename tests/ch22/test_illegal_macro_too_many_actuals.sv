/*
:name: test_illegal_macro_too_many_actuals
:description: A macro use cannot give more actual arguments than the macro has formal arguments (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the use of ADD2 gives three actual arguments to a macro with two formal arguments
:expected_stderr_regex: test_illegal_macro_too_many_actuals\.sv:23:
*/
// IEEE 1800-2023 §22.5.1: it shall be an error to specify more actual
// arguments than the number of formal arguments of the macro. ADD2 has two
// formal arguments; its first use gives two and is legal, the second gives
// three.

`define ADD2(a, b) ((a) + (b))

module test_illegal_macro_too_many_actuals;
  localparam int OK = `ADD2(1, 2);
  localparam int BAD = `ADD2(1, 2, 3);  // illegal: three actual arguments
endmodule
