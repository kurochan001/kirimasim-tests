/*
:name: test_illegal_type_reference_with_relational_operator
:description: a type reference used as a constant primary can be the type of a static cast or an operand of the equality and case equality operators, but not of other operators (IEEE 1800-2023 Section 11.11)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type references type(a) and type(int) are operands of the relational operator <
:expected_stderr_regex: test_illegal_type_reference_with_relational_operator\.sv:29:
*/
// IEEE 1800-2023 §11.11 (Syntax 11-7, footnote 45): a type_reference constant
// primary may be the casting type of a static cast, and it shall be illegal
// to use one with any operators except ==, !=, === and !==. The cast
// type(a)'(...) and the comparisons with ==, !=, === and !== are legal; the
// comparison with < is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal comparisons of
// type references, so its error does not count.

module test_illegal_type_reference_with_relational_operator;
  int a;
  byte b;
  localparam bit SAME = (type(a) == type(int));
  localparam bit DIFF = (type(a) != type(b));
  localparam bit CSAME = (type(a) === type(int));
  localparam bit CDIFF = (type(a) !== type(b));
  localparam bit LESS = (type(a) < type(int));   // illegal: a relational operator

  initial begin
    a = type(a)'(3.7);
    $display("%0d %b %b %b %b", a, SAME, DIFF, CSAME, CDIFF);
  end
endmodule
