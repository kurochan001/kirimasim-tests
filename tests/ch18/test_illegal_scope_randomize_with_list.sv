/*
:name: test_illegal_scope_randomize_with_list
:description: a scope randomize call with a parenthesized identifier list after with is an error (IEEE 1800-2023 Section 18.7)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.7 18.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the scope randomize call std::randomize(x) has the identifier list (x) after with, which only a randomize() method call of an object can have
:expected_stderr_regex: test_illegal_scope_randomize_with_list\.sv:37:
*/
// IEEE 1800-2023 §18.7 (Syntax 18-12, footnote 43): in a randomize call that
// is not a method call of an object, a scope randomize (§18.12), the
// parenthesized identifier list after with is illegal, and so is null as
// the argument. On a method call of an object the list is legal: it names
// the members that are looked up in the object, here v. The scope randomize
// with a plain inline constraint is legal. The scope randomize with the list
// (x) after with is the error. test_illegal_scope_randomize_null has null.
// Icarus Verilog 13.0 does not support randomize, so its error does not
// count. The 5.052 release of Verilator only warns that x of the list is not
// used in the constraint, and accepts the design.

class srw_obj;
  rand bit [3:0] v;
endclass

module test_illegal_scope_randomize_with_list;
  bit [3:0] x, v;
  srw_obj o = new;
  int r1, r2, r3;

  initial begin
    r1 = o.randomize() with (v) { v < 4; };
    r2 = std::randomize(x) with { x > 3; };
    r3 = std::randomize(x) with (x) { x < 9; };   // illegal: list after with
    $display("%0d %0d %0d", r1, r2, r3);
  end
endmodule
