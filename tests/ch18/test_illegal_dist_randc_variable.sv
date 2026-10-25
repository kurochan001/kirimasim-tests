/*
:name: test_illegal_dist_randc_variable
:description: A dist applied to a randc variable is an error (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3 18.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the dist of c_bad is applied to the randc variable k
:expected_stderr_regex: test_illegal_dist_randc_variable\.sv:25:
*/
// IEEE 1800-2023 §18.5.3: a dist operation shall not be applied to a randc
// variable (18.4.2). The dist of c_ok applies to the rand variable v and is
// legal, and k may be constrained with inside; the dist of c_bad applies to
// k.
// Icarus Verilog 13.0 does not support dist, so the syntax error it reports
// does not count.

class drv_obj;
  rand bit [3:0] v;
  randc bit [3:0] k;
  constraint c_ok { v dist {[0:7] := 1, [8:15] := 2}; k inside {[0:7]}; }
  constraint c_bad { k dist {[0:3] := 1, [4:7] := 2}; }   // illegal: k is randc
endclass

module test_illegal_dist_randc_variable;
  drv_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
