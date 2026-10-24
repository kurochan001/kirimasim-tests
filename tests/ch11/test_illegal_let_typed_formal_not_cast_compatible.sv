/*
:name: test_illegal_let_typed_formal_not_cast_compatible
:description: the actual argument for a typed formal argument of a let, other than event, has to be cast compatible with the type of the formal (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class handle h is the actual argument of the formal argument x of type byte of the let low_byte
:expected_stderr_regex: test_illegal_let_typed_formal_not_cast_compatible\.sv:36:
*/
// IEEE 1800-2023 §11.12: for a typed formal argument of a let that is not of
// type event, the self-determined type of the actual argument shall be cast
// compatible (6.22.4) with the type of the formal, and the actual is cast to
// that type before it is substituted. The int w and the real r are cast
// compatible with byte, which is legal; the class handle h is not.
// Icarus Verilog 13.0 does not support let declarations.
// The 5.052 release of Verilator reports typed let ports as unsupported.

class obj_c;
endclass

module test_illegal_let_typed_formal_not_cast_compatible;
  int w = 32'h1234;
  real r = 2.0;
  obj_c h = new;
  int v1, v2, v3;

  let low_byte(byte x) = x + 1;

  initial begin
    v1 = low_byte(w);
    v2 = low_byte(r);
    v3 = low_byte(h);   // illegal: a class handle is not cast compatible with byte
    $display("%0d %0d", v1, v2);
  end
endmodule
