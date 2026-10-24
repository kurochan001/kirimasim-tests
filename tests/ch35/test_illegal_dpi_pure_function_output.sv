/*
:name: test_illegal_dpi_pure_function_output
:description: An imported function with an output argument cannot be declared pure, since a pure function returns its result only through its value and depends only on its inputs (IEEE 1800-2023 Section 35.5.1.3)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.1.3 35.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an imported function declared pure has an output argument
:expected_stderr_regex: test_illegal_dpi_pure_function_output\.sv:23:
*/
// IEEE 1800-2023 §35.5.1.3: only a function whose result depends solely on
// its inputs and that has no side effects can be specified as pure; 35.5.2
// makes this concrete: only nonvoid functions with no output or inout
// arguments can be pure. c_split is declared pure and writes its result to
// the output hi, which is an error at its declaration.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on that
// line does not count. Verilator 5.052 accepts the design.

module test_illegal_dpi_pure_function_output;
  import "DPI-C" pure function int c_split(input int v, output int hi);   // illegal: output

  initial begin
    int hi;
    $display("%0d", c_split(5, hi));
  end
endmodule
