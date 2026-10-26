/*
:name: test_illegal_constraint_struct_operand
:description: A constraint expression may not have an unpacked structure operand that contains a random variable, while a string comparison without random variables is allowed as a subexpression whose result is integral (IEEE 1800-2023 Section 18.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint c_bad compares the rand unpacked structure s with a structure pattern
:expected_stderr_regex: test_illegal_constraint_struct_operand\.sv:34:
*/
// IEEE 1800-2023 §18.3: a constraint may contain operands of integral or real
// types only; a subexpression may contain another type when it has no random
// variables and its result is integral or real. The constraint c_ok compares
// the state string str with a string literal in the condition of an
// implication, whose result is integral and which contains no random variable,
// so it is legal. The constraint c_bad compares the random unpacked structure
// s, whose result is a structure and not an integral value, so it is illegal.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052
// accepts the design, so their results do not count.

typedef struct {
  int a;
} cos_t;

class cos_obj;
  rand cos_t s;
  int x;
  string str = "abc";

  constraint c_ok { (str == "abc") -> x == 1; }
  constraint c_bad { s == '{a: 1}; }   // illegal: structure operand
endclass

module test_illegal_constraint_struct_operand;
  cos_obj o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
