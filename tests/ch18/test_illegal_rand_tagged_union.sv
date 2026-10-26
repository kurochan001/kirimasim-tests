/*
:name: test_illegal_rand_tagged_union
:description: A packed tagged union shall not be declared rand or randc (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class declares u, a packed tagged union, as rand
:expected_stderr_regex: test_illegal_rand_tagged_union\.sv:26:
// Icarus Verilog 13.0 does not support tagged unions, so its syntax errors
// on the typedef and the declaration do not count. Verilator 5.052 stops on
// the void member before it reaches the declaration.
*/
// IEEE 1800-2023 §18.4: packed tagged unions shall not be declared rand or
// randc, because the tag selects the member and the members are not all of
// the same type. The declaration of u is illegal.

class c_tagged_union;
  typedef union tagged packed {
    void Invalid;
    int Valid;
  } tagged_t;
  rand tagged_t u;   // illegal: packed tagged union
endclass

module test_illegal_rand_tagged_union;
  c_tagged_union o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
