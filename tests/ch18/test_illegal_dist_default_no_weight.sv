/*
:name: test_illegal_dist_default_no_weight
:description: The default item of a dist without :/ and a weight is an error (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default item of the distribution of x has no :/ operator and no weight
:expected_stderr_regex: test_illegal_dist_default_no_weight\.sv:22:
*/
// IEEE 1800-2023 §18.5.3: the default specification always uses the :/
// operator with a weight, and it is an error if :/ is omitted. The dist of y
// writes default :/ 2 and is legal; the dist of x writes default alone.
// Icarus Verilog 13.0 does not support dist, so the syntax error it reports on
// that line does not count.

class ddn_obj;
  rand bit [7:0] x, y;
  constraint cx { x dist {[0:3] :/ 1, default}; }   // illegal: no :/ weight
  constraint cy { y dist {[0:3] :/ 1, default :/ 2}; }
endclass

module test_illegal_dist_default_no_weight;
  ddn_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule

// Oracle check: the 5.052 release of Verilator reports a syntax error on line
// 22 that expects :/ there, but it reports the legal default :/ 2 of line 23
// as unsupported, so its error does not count.
