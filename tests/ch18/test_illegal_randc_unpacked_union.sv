/*
:name: test_illegal_randc_unpacked_union
:description: an unpacked union declared randc is an error (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class member u is an unpacked union declared randc
:expected_stderr_regex: test_illegal_randc_unpacked_union\.sv:27:
*/
// IEEE 1800-2023 §18.4: unpacked unions shall not be declared rand or randc.
// A packed untagged union can be declared randc, so the member p is legal.
// The member u is an unpacked union declared randc, which is the error.
// test_illegal_rand_unpacked_union declares one rand.
// Icarus Verilog 13.0 does not support unpacked unions, so its error does
// not count. The 5.052 release of Verilator stops on that line with an
// internal error about the type of a randc variable, not with a diagnostic
// of the rule, so its error does not count either.

class rcu_obj;
  randc union packed { bit [3:0] a; bit [3:0] b; } p;
  rand int n;

  randc union { bit [3:0] i; bit [3:0] c; } u;   // illegal: unpacked union declared randc
endclass

module test_illegal_randc_unpacked_union;
  rcu_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
