/*
:name: test_illegal_signing_cast_of_real
:description: the expression of a signing cast has to be integral; a real expression cannot be cast with signed' (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the signing cast signed'(r) is applied to the real variable r
:expected_stderr_regex: test_illegal_signing_cast_of_real\.sv:25:
*/
// IEEE 1800-2023 §6.24.1: the expression inside a cast shall be an integral
// value when the cast changes the size or the signing. The signing casts of
// a vector and of an int are legal; the last cast changes the signing of
// the real r.

module test_illegal_signing_cast_of_real;
  bit [3:0] v = 4'b1110;
  int i = -1;
  real r = -2.5;
  initial begin
    $display("%0d %0d", signed'(v), unsigned'(i));
    $display("%0d", signed'(r));   // illegal: signing cast of a real
  end
endmodule
