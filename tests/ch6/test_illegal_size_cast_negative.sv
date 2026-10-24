/*
:name: test_illegal_size_cast_negative
:description: the size of a size cast has to be a positive constant; a cast to a negative size is an error (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the size cast (W - 8)'(v) has the size -2
:expected_stderr_regex: test_illegal_size_cast_negative\.sv:25:
*/
// IEEE 1800-2023 §6.24.1: when the casting type is a constant expression
// with a positive integral value, the expression is padded or truncated to
// that size, and it is an error if the size is zero or negative. The casts
// to the constant expressions W - 5 (1) and W + 4 (10) are legal; the last
// cast is to W - 8, which is -2.

module test_illegal_size_cast_negative;
  parameter int W = 6;
  bit [7:0] v = 8'hb5;
  initial begin
    $display("%b %b", (W - 5)'(v), (W + 4)'(v));
    $display("%b", (W - 8)'(v));   // illegal: negative size
  end
endmodule
