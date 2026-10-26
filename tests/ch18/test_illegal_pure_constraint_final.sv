/*
:name: test_illegal_pure_constraint_final
:description: A pure constraint shall not use the final specifier, so a pure constraint declared with final is an error (IEEE 1800-2023 Sections 18.5 and 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure constraint c_final of pcf_abstract is declared with the final specifier
:expected_stderr_regex: test_illegal_pure_constraint_final\.sv:24:
*/
// IEEE 1800-2023 §18.5.2: a pure constraint is a constraint prototype that
// uses the pure keyword, and it may be qualified static. §18.5: a pure
// constraint shall not use the final specifier. The pure constraint c_need is
// legal; c_final has final and is illegal. Both are implemented in the
// non-abstract class pcf_concrete.

virtual class pcf_abstract;
  rand int v;

  pure constraint c_need;
  pure constraint : final c_final;   // illegal: pure constraint with final
endclass

class pcf_concrete extends pcf_abstract;
  constraint c_need { v > 0; }
  constraint c_final { v < 100; }
endclass

module test_illegal_pure_constraint_final;
  pcf_concrete o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
