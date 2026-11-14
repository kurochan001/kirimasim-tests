/*
:name: test_illegal_string_putc_result_assigned
:description: the string method putc returns void, so a call of it cannot be the right-hand side of an assignment (IEEE 1800-2023 Section 6.16.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16.2 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of the void string method putc is the right-hand side of an assignment to an int
:expected_stderr_regex: test_illegal_string_putc_result_assigned\.sv:30:
*/
// IEEE 1800-2023 §6.16.2 declares putc as a function whose return type is
// void, and §13.4.1 lets the call of a void function be a statement but not
// an expression. The first call of putc below is a statement and is legal;
// the second is the right-hand side of an assignment to the int r, which
// uses the call as a value.
// Oracle checks: Icarus Verilog 13.0 reports the marked line, but because
// it does not know putc there, and it rejects the legal call on the line
// before as an unknown task as well; the 5.054 release of Verilator stops
// on the marked line with an internal error. Neither is an oracle here.

module test_illegal_string_putc_result_assigned;
  string s;
  int r;
  initial begin
    s = "abc";
    s.putc(0, "x");
    r = s.putc(1, "y");   // illegal: putc has no value to assign
    $display("%s %0d", s, r);
  end
endmodule
