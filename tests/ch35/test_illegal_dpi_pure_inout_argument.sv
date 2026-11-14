/*
:name: test_illegal_dpi_pure_inout_argument
:description: An imported function with an inout argument cannot be declared pure, even when it has a result, since only nonvoid functions without output or inout arguments can be pure (IEEE 1800-2023 Section 35.5.2)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an imported function declared pure has an inout argument
:expected_stderr_regex: test_illegal_dpi_pure_inout_argument\.sv:29:
*/
// IEEE 1800-2023 §35.5.2: the pure property is allowed only on a function
// that returns a value and has no output or inout arguments. A pure call
// may be removed when its value is not needed, which would lose any value
// that the call passes back through an argument.
//
// c_scaled has an int result and two inputs, so it can be pure. c_bump has
// an int result as well, but its second argument is inout, so declaring it
// pure is an error at its declaration. Without the word pure on that line
// the design is legal.
//
// Icarus Verilog 13.0 has no DPI, so an error it reports on that line does
// not count. The 5.054 release of Verilator accepts the design.

module test_illegal_dpi_pure_inout_argument;
  import "DPI-C" pure function int c_scaled(input int v, input int k);
  import "DPI-C" pure function int c_bump(input int v, inout int acc);

  initial begin
    int acc;
    acc = 1;
    $display("%0d", c_scaled(3, 2));
    $display("%0d", c_bump(4, acc));
  end
endmodule
