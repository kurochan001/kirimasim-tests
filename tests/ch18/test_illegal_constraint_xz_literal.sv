/*
:name: test_illegal_constraint_xz_literal
:description: Constraints support only two-state values, so an x or z literal in a constraint expression is an error although ordinary 0 and 1 values are allowed (IEEE 1800-2023 Section 18.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the constraint c compares the random variable with the four-state literal 4'b1x0z
:expected_stderr_regex: test_illegal_constraint_xz_literal\.sv:25:
*/
// IEEE 1800-2023 §18.3: constraints support only two-state values; x and z
// literals and four-state operators such as === and !== are illegal. The
// constraint ok uses only the two-state value 4'b1010 and is legal. The
// constraint c contains 4'b1x0z, which has an x and a z bit, and is illegal.
// The random variable v is a two-state bit vector, as a constraint requires;
// only the literal in c is four-state.

class c_xz;
  rand bit [3:0] v;

  constraint ok { v == 4'b1010; }
  constraint c { v == 4'b1x0z; }   // illegal: x and z in a constraint
endclass

module test_illegal_constraint_xz_literal;
  c_xz o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
