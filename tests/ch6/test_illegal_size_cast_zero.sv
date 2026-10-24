/*
:name: test_illegal_size_cast_zero
:description: the size of a size cast has to be a positive constant; a cast to size zero is an error (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the size cast 0'(v) has the size zero
:expected_stderr_regex: test_illegal_size_cast_zero\.sv:25:
*/
// IEEE 1800-2023 §6.24.1: when the casting type is a constant expression
// with a positive integral value, the expression is padded or truncated to
// that size, and it is an error if the size is zero or negative. The casts
// to 1 bit, which is the smallest legal size, and to the parameter W are
// legal; the last cast has the size zero.

module test_illegal_size_cast_zero;
  parameter int W = 6;
  bit [7:0] v = 8'hb5;
  initial begin
    $display("%b %b", 1'(v), W'(v));
    $display("%b", 0'(v));   // illegal: size zero
  end
endmodule
