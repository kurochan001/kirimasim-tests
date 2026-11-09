/*
:name: test_illegal_randc_real_array
:description: An array declared randc makes all its elements randc, so a randc array of real elements is an error, while a rand array of reals and a randc array of integral elements are legal (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4 6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array rb of real elements is declared randc, which makes each of its real elements randc
:expected_stderr_regex: test_illegal_randc_real_array\.sv:28:
*/
// IEEE 1800-2023 §18.4: an array declared rand or randc treats all its
// elements as rand or randc, and real variables shall not be randc (§6.12:
// real, shortreal and realtime variables are real variables). ra, an array of
// real declared rand, and rc, an array of 2-bit elements declared randc, are
// legal. rb is an array of real declared randc, so each of its real elements
// would be randc, which is an error.
// Icarus Verilog 13.0 reports only that randomize() is missing. The 5.052
// release of Verilator stops on line 28 because a randc variable is wider than
// 32 bits, not because its elements are real, so its error does not show the
// rule.

class rca_obj;
  rand real ra[2];
  randc bit [1:0] rc[2];
  randc real rb[2];   // illegal: real elements would be randc
endclass

module test_illegal_randc_real_array;
  rca_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
