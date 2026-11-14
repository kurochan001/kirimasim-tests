/*
:name: test_illegal_string_putc_result_in_expression
:description: the string method putc returns void, so a call of it cannot be an operand of an operator (IEEE 1800-2023 Section 6.16.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16.2 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of the void string method putc is an operand of the equality operator in an if condition
:expected_stderr_regex: test_illegal_string_putc_result_in_expression\.sv:29:
*/
// IEEE 1800-2023 §6.16.2 declares putc as a function whose return type is
// void, and §13.4.1 lets the call of a void function be a statement but not
// an expression. The first call of putc below is a statement and is legal;
// the second is an operand of == in the condition of an if statement, with
// no assignment involved, which uses the call as a value.
// Oracle checks: Icarus Verilog 13.0 reports the marked line, but because
// it does not know putc there, and it rejects the legal call on the line
// before as an unknown task as well; the 5.054 release of Verilator stops
// on the marked line with an internal error. Neither is an oracle here.

module test_illegal_string_putc_result_in_expression;
  string s;
  initial begin
    s = "abc";
    s.putc(0, "x");
    if (s.putc(1, "y") == 0)   // illegal: putc has no value to compare
      $display("equal");
    $display("%s", s);
  end
endmodule
