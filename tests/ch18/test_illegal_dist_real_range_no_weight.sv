/*
:name: test_illegal_dist_real_range_no_weight
:description: A range of real values in a dist without a weight is an error (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the range of real values [1.0:2.0] in the distribution of r has no weight
:expected_stderr_regex: test_illegal_dist_real_range_no_weight\.sv:25:
*/
// IEEE 1800-2023 §18.5.3: a range of real values in a distribution shall use
// the :/ operator and shall specify a weight; only an integral item may omit
// its weight, which is then := 1. In the dist of s the integral item 3 has no
// weight, which is legal, and the real range has :/ 1; in the dist of r the
// real range has no weight. (A real variable can be rand, 18.4.)
// Icarus Verilog 13.0 does not support dist, and Verilator 5.052 does not
// support real values in a dist, so the errors they report on that line do not
// count.

class drn_obj;
  rand real r, s;
  constraint cr { r dist {[1.0:2.0], 3 := 1}; }   // illegal: real range without a weight
  constraint cs { s dist {3, [1.0:2.0] :/ 1}; }
endclass

module test_illegal_dist_real_range_no_weight;
  drn_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
