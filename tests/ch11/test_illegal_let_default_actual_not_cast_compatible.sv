/*
:name: test_illegal_let_default_actual_not_cast_compatible
:description: the default actual argument of a typed let formal follows the same cast compatibility rule as an actual argument (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default actual argument of the byte formal x of the let low is the event e, which is not cast compatible with byte
:expected_stderr_regex: test_illegal_let_default_actual_not_cast_compatible\.sv:(34|38):
*/
// IEEE 1800-2023 §11.12: the rules for typed formal arguments of a let and
// their actual arguments include the default actual arguments declared in
// the let. For a formal of a type other than event, the self-determined type
// of the actual shall be cast compatible (§6.22.4) with the type of the
// formal. The let pick has the byte formal y with the int n as its default,
// which is legal; the let low has the byte formal x with the event e as its
// default, and an event is not cast compatible with an integral type
// (§15.5.5 lets it be assigned only an event or null and compared only).
// low() uses that default. A tool can report the error at the declaration
// (line 34) or where the default is used (line 38).
// Icarus Verilog 13.0 does not support let declarations, and the 5.054
// release of Verilator reports typed let ports as unsupported; neither
// error is the diagnostic of this rule.

module test_illegal_let_default_actual_not_cast_compatible;
  event e;
  int n = 7;
  int a, b;

  let pick(byte y = n) = y + 1;
  let low(byte x = e) = x + 1;   // illegal: an event as default of a byte formal

  initial begin
    a = pick();
    b = low();
  end
endmodule
