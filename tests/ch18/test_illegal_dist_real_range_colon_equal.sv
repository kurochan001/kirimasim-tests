/*
:name: test_illegal_dist_real_range_colon_equal
:description: A range of real values in a dist with the := operator is an error (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the range of real values [1.0:2.0] in the distribution of r has its weight given with :=
:expected_stderr_regex: test_illegal_dist_real_range_colon_equal\.sv:25:
*/
// IEEE 1800-2023 §18.5.3: the items of a distribution can be integral or
// real values and ranges, but a range of real values shall use the :/
// operator and give a weight. In the dist of s, the single real value 0.5
// with := and the real range with :/ are legal; in the dist of r the real
// range has :=. (A real variable can be rand, 18.4.)
// Icarus Verilog 13.0 does not support dist, and Verilator 5.052 does not
// support real values in a dist, so the errors they report on that line do not
// count.

class drc_obj;
  rand real r, s;
  constraint cr { r dist {[1.0:2.0] := 1, 3 := 1}; }   // illegal: := on a real range
  constraint cs { s dist {0.5 := 1, [1.0:2.0] :/ 1}; }
endclass

module test_illegal_dist_real_range_colon_equal;
  drc_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
