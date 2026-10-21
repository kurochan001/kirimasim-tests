/*
:name: test_illegal_dist_default_colon_equal
:description: The default item of a dist uses :/ and not := (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default item of the distribution gives its weight with :=
:expected_stderr_regex: test_illegal_dist_default_colon_equal\.sv:21:
*/
// IEEE 1800-2023 §18.5.3: the default specification shall always use the :/
// operator, which spreads the weight over the values it stands for.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so the
// error it reports on that line does not count.

class test_illegal_dist_default_colon_equal_c;
  rand bit [7:0] x;
  constraint cx { x dist {[0:3] :/ 1, default := 1}; }   // illegal: := for default
endclass

module test_illegal_dist_default_colon_equal;
  test_illegal_dist_default_colon_equal_c o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
