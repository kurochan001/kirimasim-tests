/*
:name: test_illegal_forward_typedef_defined_in_generate_block
:description: the actual type of a forward typedef has to be defined in the same scope; a definition inside a generate block does not resolve a forward typedef of the module (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: inner_t is declared forward in the module but defined only inside the generate block g
:expected_stderr_regex: test_illegal_forward_typedef_defined_in_generate_block\.sv:26:
*/
// IEEE 1800-2023 §6.18: the actual type of a forward typedef shall be defined
// in the same local scope or generate block, and it is an error if the name
// does not resolve to a data type.
// ok_t is declared forward in the module and defined there, and the generate
// block g declares and uses its own type inner_t; the legal design prints a
// value of ok_t and the variable of g: 1 3. The module also declares inner_t
// forward, and nothing in the module defines it.
// Icarus Verilog 13.0 and the 5.052 release accept the design.

module test_illegal_forward_typedef_defined_in_generate_block;
  typedef enum ok_t;
  typedef enum {A, B} ok_t;
  typedef inner_t;   // illegal: defined only in the generate block g
  if (1) begin : g
    typedef int inner_t;
    inner_t v = 3;
  end
  ok_t o = B;
  initial $display("%0d %0d", o, g.v);
endmodule
