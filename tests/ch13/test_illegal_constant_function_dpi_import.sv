/*
:name: test_illegal_constant_function_dpi_import
:description: a DPI import function cannot be called as a constant function (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam P is initialized by a call of the DPI import function c_twice
:expected_stderr_regex: test_illegal_constant_function_dpi_import\.sv:28:
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not be a DPI import
// function (35.2.1). c_twice is imported as a pure function with a constant
// argument, so the only constraint its call in the initial value of P breaks
// is this one. The localparam Q, initialized by a call of the SystemVerilog
// function twice, is legal.
// Icarus Verilog 13.0 does not support DPI imports and reports a syntax error
// on the import declaration, which does not count.

module test_illegal_constant_function_dpi_import;
  import "DPI-C" pure function int c_twice(input int a);
  function int twice(input int a);
    return 2 * a;
  endfunction
  localparam int Q = twice(3);
  localparam int P = c_twice(3);   // illegal
  initial $display("%0d %0d", P, Q);
endmodule
