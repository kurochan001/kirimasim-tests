/*
:name: test_illegal_let_chandle_typed_formal
:description: a typed formal argument of a let is of type event or of a type allowed in Boolean expressions of assertions, which chandle is not (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the formal argument h of the let is_null is declared with the type chandle, which is neither event nor a type allowed in 16.6
:expected_stderr_regex: test_illegal_let_chandle_typed_formal\.sv:(33|37):
*/
// IEEE 1800-2023 §11.12: if a formal argument of a let is typed, the type
// shall be event or one of the types allowed in §16.6. §16.6 allows a type
// that is cast compatible with an integral type and rules out references to
// chandle variables; a chandle is not cast compatible with any integral type
// (§6.14 forbids assigning it to a variable of another type and lists its
// few legal uses). The let is_set declares its formal with the type bit,
// which is legal; is_null declares its formal h as chandle. A tool can
// report the error at the declaration (line 33) or where is_null is used
// (line 37).
// Icarus Verilog 13.0 does not support let declarations, and the 5.054
// release of Verilator reports typed let ports as unsupported; neither
// error is the diagnostic of this rule.

module test_illegal_let_chandle_typed_formal;
  chandle ch;
  logic v = 1'b1;
  bit a, b;

  let is_set(bit x) = x == 1'b1;
  let is_null(chandle h) = h == null;   // illegal: chandle formal type

  initial begin
    a = is_set(v);
    b = is_null(ch);
  end
endmodule
