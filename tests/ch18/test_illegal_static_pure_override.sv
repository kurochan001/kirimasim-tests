/*
:name: test_illegal_static_pure_override
:description: A pure constraint may be qualified static, and an overriding constraint shall match that qualification, so a non-static override of a static pure constraint is an error (IEEE 1800-2023 Section 18.5.10)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.10 18.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c_bad is a static pure constraint of spo_abstract but its override in spo_concrete is not static
:expected_stderr_regex: test_illegal_static_pure_override\.sv:31:
*/
// IEEE 1800-2023 §18.5.10: a pure constraint may be qualified static, and
// any constraint that overrides it shall match the pure constraint's
// qualification. c_ok is a static pure constraint and spo_static overrides it
// with a static constraint, which is legal. c_bad is static pure and
// spo_concrete overrides it with a non-static constraint, which is illegal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design, so their results
// do not count.

virtual class spo_abstract;
  rand int v;

  pure static constraint c_ok;
  pure static constraint c_bad;
endclass

class spo_static extends spo_abstract;
  static constraint c_ok { v > -10; }
  constraint c_bad { v < 10; }   // illegal: override not static
endclass

module test_illegal_static_pure_override;
  spo_static o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
