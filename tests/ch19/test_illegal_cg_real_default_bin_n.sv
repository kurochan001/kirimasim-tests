/*
:name: test_illegal_cg_real_default_bin_n
:description: a default bin of a real coverpoint shall not use the [N] bin-array notation (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default bin rest of the real coverpoint bad is declared with [2]
:expected_stderr_regex: test_illegal_cg_real_default_bin_n\.sv:30:
*/
// IEEE 1800-2023 §19.5.1: a default bin for a real expression shall not have
// an array of bins; neither [] nor [N] is allowed. The real coverpoint plain
// has the permitted single default bin rest, and both real coverpoints have a
// value bin. The coverpoint bad declares its default bin as rest[2], which is
// the one error.

module test_illegal_cg_real_default_bin_n;
  real r;

  covergroup cg;
    plain: coverpoint r {
      bins lo = {[0.0:1.0]};
      bins rest = default;
    }
    bad: coverpoint r {
      bins lo = {[0.0:1.0]};
      bins rest[2] = default;   // illegal: [N] default bin of a real point
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule
