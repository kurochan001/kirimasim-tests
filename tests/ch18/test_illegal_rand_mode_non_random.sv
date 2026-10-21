/*
:name: test_illegal_rand_mode_non_random
:description: Calling rand_mode() on a class property that is not declared rand or randc is a compile error (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: rand_mode() is called on a property that is neither rand nor randc
:expected_stderr_regex: test_illegal_rand_mode_non_random\.sv:28:
*/
// IEEE 1800-2023 §18.8: a compiler error shall be issued when the variable
// that rand_mode() is called on does not exist in the class hierarchy, or
// exists but is not declared rand or randc; count is a plain property.
// Icarus Verilog 13.0 does not support rand_mode() or randomize() at all, so
// the error it reports on that line does not count.

class test_illegal_rand_mode_non_random_c;
  rand int v;
  int count;
endclass

module test_illegal_rand_mode_non_random;
  test_illegal_rand_mode_non_random_c o = new;
  initial begin
    o.count.rand_mode(0);   // illegal: count is not rand or randc
    $display("ok=%0d", o.randomize());
  end
endmodule
