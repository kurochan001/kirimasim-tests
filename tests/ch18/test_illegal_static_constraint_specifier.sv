/*
:name: test_illegal_static_constraint_specifier
:description: A dynamic override specifier shall not be used with a static constraint, so static constraint :final c is an error while a plain static constraint and a nonstatic :final constraint are legal (IEEE 1800-2023 Section 18.5.10)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the static constraint c is declared with the dynamic override specifier :final
:expected_stderr_regex: test_illegal_static_constraint_specifier\.sv:25:
*/
// IEEE 1800-2023 §18.5.10: a constraint block is made static with the static
// keyword, and it shall be illegal to use the dynamic override specifiers
// (:initial, :extends and :final) with a static constraint. The plain static
// constraint s_ok and the nonstatic constraint :final d_ok are legal. The
// static constraint :final c combines the two and is illegal.

class c_static;
  rand int x;

  static constraint s_ok { x < 100; }
  constraint :final d_ok { x > -100; }
  static constraint :final c { x != 0; }   // illegal: static with :final
endclass

module test_illegal_static_constraint_specifier;
  c_static o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
