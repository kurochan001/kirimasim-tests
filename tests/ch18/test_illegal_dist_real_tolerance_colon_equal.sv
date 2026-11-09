/*
:name: test_illegal_dist_real_tolerance_colon_equal
:description: A tolerance range around a real value is a range of real values, so in a dist it shall take a :/ weight and := is an error, while an integral tolerance range may use := (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real tolerance range [1.0 +%- 10.0] in the distribution of r has its weight given with :=
:expected_stderr_regex: test_illegal_dist_real_tolerance_colon_equal\.sv:32:
*/
// IEEE 1800-2023 §11.4.13: [A +/- B] and [A +%- B] are ranges of the type of
// A. §18.5.3: a range of real values in a dist shall use the :/ operator with
// a weight; := is allowed for a single real value and for integral ranges,
// and the example of §18.5.3 gives a relative tolerance range around a real
// value its weight with :/. In cn the tolerance range of the int 10 is an
// integral range and may use :=; in cs the absolute tolerance range around
// 1.0 uses :/ and the single real 0.5 uses :=, both legal. In cr the relative
// tolerance range around 1.0, the real range [0.9:1.1], uses :=, which is an
// error.
// Icarus Verilog 13.0 does not support dist, so the syntax error it reports on
// line 32 does not count. The 5.052 release of Verilator stops at the
// tolerance range of line 30, which it does not support.

class drt_obj;
  rand int n;
  rand real r, s;
  constraint cn { n dist {[10 +/- 2] := 1, 20 := 1}; }
  constraint cs { s dist {[1.0 +/- 0.1] :/ 1, 0.5 := 1}; }
  constraint cr { r dist {[1.0 +%- 10.0] := 1, 0.5 := 1}; }   // illegal: := on a real range
endclass

module test_illegal_dist_real_tolerance_colon_equal;
  drt_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
