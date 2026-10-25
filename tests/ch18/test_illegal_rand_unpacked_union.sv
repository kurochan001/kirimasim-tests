/*
:name: test_illegal_rand_unpacked_union
:description: an unpacked union declared rand is an error (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class member u is an unpacked union declared rand
:expected_stderr_regex: test_illegal_rand_unpacked_union\.sv:25:
*/
// IEEE 1800-2023 §18.4: unpacked unions shall not be declared rand or randc.
// A packed untagged union can be declared rand, so the member p is legal.
// The member u is an unpacked union declared rand, which is the error.
// test_illegal_randc_unpacked_union declares one randc.
// Icarus Verilog 13.0 does not support unpacked unions, so its error does
// not count.

class ruu_obj;
  rand union packed { bit [7:0] a; bit [7:0] b; } p;
  rand int n;

  rand union { int i; bit [7:0] c; } u;   // illegal: unpacked union declared rand
endclass

module test_illegal_rand_unpacked_union;
  ruu_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
