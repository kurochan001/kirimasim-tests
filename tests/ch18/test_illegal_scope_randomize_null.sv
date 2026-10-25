/*
:name: test_illegal_scope_randomize_null
:description: a scope randomize call with null as its argument is an error (IEEE 1800-2023 Section 18.7)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.7 18.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the scope randomize call std::randomize(null) passes null, which only a randomize() method call of an object can take
:expected_stderr_regex: test_illegal_scope_randomize_null\.sv:38:
*/
// IEEE 1800-2023 §18.7 (Syntax 18-12, footnote 43): in a randomize call that
// is not a method call of an object, a scope randomize (§18.12), the use of
// null as the argument is illegal, and so is the parenthesized identifier
// list after with. A scope randomize of the variable x with an inline
// constraint is legal, and so is randomize(null) as a method call of an
// object, which only checks its constraints. The call std::randomize(null)
// is the error. test_illegal_scope_randomize_with_list has the identifier
// list.
// Icarus Verilog 13.0 does not support randomize, so its error does not
// count.

class srn_obj;
  rand bit [3:0] v;
  constraint c { v < 8; }
endclass

module test_illegal_scope_randomize_null;
  bit [3:0] x;
  srn_obj o = new;
  int r1, r2, r3;

  initial begin
    r1 = std::randomize(x) with { x > 3; };
    r2 = o.randomize(null);
    r3 = std::randomize(null);   // illegal: null in a scope randomize
    $display("%0d %0d %0d", r1, r2, r3);
  end
endmodule
