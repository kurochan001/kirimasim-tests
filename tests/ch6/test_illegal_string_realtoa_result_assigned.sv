/*
:name: test_illegal_string_realtoa_result_assigned
:description: the string method realtoa returns void, so a call of it cannot be the right-hand side of an assignment (IEEE 1800-2023 Section 6.16.15)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16.15 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of the void string method realtoa is the right-hand side of an assignment to an int
:expected_stderr_regex: test_illegal_string_realtoa_result_assigned\.sv:29:
*/
// IEEE 1800-2023 §6.16.15 declares realtoa as a function whose return type
// is void, and §13.4.1 lets the call of a void function be a statement but
// not an expression. The first call of realtoa below is a statement and is
// legal; the second is the right-hand side of an assignment to the int r,
// which uses the call as a value.
// Oracle checks: Icarus Verilog 13.0 reports the marked line, but with the
// message that realtoa is not a string method, not that the method has no
// value; the 5.054 release of Verilator stops on the marked line with an
// internal error. Neither is an oracle here.

module test_illegal_string_realtoa_result_assigned;
  string s;
  int r;
  initial begin
    s.realtoa(2.5);
    r = s.realtoa(1.5);   // illegal: realtoa has no value to assign
    $display("%s %0d", s, r);
  end
endmodule
