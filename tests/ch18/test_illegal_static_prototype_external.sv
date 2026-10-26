/*
:name: test_illegal_static_prototype_external
:description: The static keyword shall be applied to both a constraint prototype and its external constraint block or to neither, so a static prototype with a non-static external block is an error (IEEE 1800-2023 Section 18.5.10)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.10 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype of c_bad is static but its external constraint block is not
:expected_stderr_regex: test_illegal_static_prototype_external\.sv:(27|32):
*/
// IEEE 1800-2023 §18.5.10: when a constraint is declared with a constraint
// prototype and an external constraint block, static has to be applied to
// both or to neither. c_ok is static on both, and c_plain is static on
// neither. The prototype of c_bad is static and its block is not, so the
// design is illegal; a tool can report the error at either of the two.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design, so their results
// do not count.

class spe_base;
  rand int v;

  static constraint c_ok;
  constraint c_plain;
  static constraint c_bad;
endclass

static constraint spe_base::c_ok { v > -10; }
constraint spe_base::c_plain { v < 10; }
constraint spe_base::c_bad { v != 5; }   // illegal: block not static

module test_illegal_static_prototype_external;
  spe_base o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
