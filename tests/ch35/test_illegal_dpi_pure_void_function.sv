/*
:name: test_illegal_dpi_pure_void_function
:description: A void imported function cannot be declared pure, since only nonvoid functions without output or inout arguments can be pure (IEEE 1800-2023 Section 35.5.2)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an imported void function is declared pure
:expected_stderr_regex: test_illegal_dpi_pure_void_function\.sv:29:
*/
// IEEE 1800-2023 §35.5.2: the pure property is allowed only on a function
// that returns a value and has no output or inout arguments, because a call
// of a pure function may be removed or replaced by an earlier result, which
// only makes sense for a call whose sole effect is its value.
//
// c_square has an int result and one input, so it can be pure. c_note has
// the same input but is a void function, so declaring it pure is an error
// at its declaration. Without the word pure on that line the design is
// legal.
//
// Icarus Verilog 13.0 has no DPI, so an error it reports on that line does
// not count. The 5.054 release of Verilator accepts the design.

module test_illegal_dpi_pure_void_function;
  import "DPI-C" pure function int c_square(input int v);
  import "DPI-C" pure function void c_note(input int v);

  initial begin
    $display("%0d", c_square(3));
    c_note(4);
  end
endmodule
