/*
:name: test_illegal_dist_two_defaults
:description: A dist can have only one default item (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the distribution has two default items
:expected_stderr_regex: test_illegal_dist_two_defaults\.sv:21:
*/
// IEEE 1800-2023 §18.5.3: there shall be at most one default specification in a
// distribution.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports default in a dist,
// so the errors they report on that line do not count.

class test_illegal_dist_two_defaults_c;
  rand bit [7:0] x;
  constraint cx { x dist {[0:3] :/ 1, default :/ 1, default :/ 2}; }   // illegal
endclass

module test_illegal_dist_two_defaults;
  test_illegal_dist_two_defaults_c o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
