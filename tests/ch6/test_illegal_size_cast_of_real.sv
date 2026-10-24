/*
:name: test_illegal_size_cast_of_real
:description: the expression of a size cast has to be integral; a real expression cannot be cast to a size (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the size cast 4'(r) is applied to the real variable r
:expected_stderr_regex: test_illegal_size_cast_of_real\.sv:27:
*/
// IEEE 1800-2023 §6.24.1: the expression inside a cast shall be an integral
// value when the cast changes the size or the signing. The size casts of an
// int and of a 4-state vector are legal, and so is the cast of the real r
// to the type int, which is not a size cast; the last cast changes the size
// of r itself.
// The 5.052 release accepts the size cast of a real expression.

module test_illegal_size_cast_of_real;
  int i = 300;
  logic [7:0] v = 8'h5a;
  real r = 2.5;
  initial begin
    $display("%0d %b %0d", 4'(i), 4'(v), int'(r));
    $display("%0d", 4'(r));   // illegal: size cast of a real
  end
endmodule
