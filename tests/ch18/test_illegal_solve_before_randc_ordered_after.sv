/*
:name: test_illegal_solve_before_randc_ordered_after
:description: a randc variable after before in a solve...before ordering constraint is an error (IEEE 1800-2023 Section 18.5)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering constraint names the randc variable k after before
:expected_stderr_regex: test_illegal_solve_before_randc_ordered_after\.sv:30:
*/
// IEEE 1800-2023 §18.5 lists the restrictions of constraint expressions;
// one of them is that randc variables shall not be named in ordering
// constraints (solve...before, §18.5.9), on either side of before. The
// ordering constraint o1 orders two rand variables, which is legal. o2 has
// the randc variable k in the list after before, which is the error. The
// relation between v, w and k, without an order, is legal.
// Icarus Verilog 13.0 does not support constraint declarations, so its error
// does not count.

class sbr_obj;
  rand bit [3:0] v;
  rand bit [3:0] w;
  randc bit [1:0] k;

  constraint rel { v > w; w > k; }
  constraint o1 { solve v before w; }
  constraint o2 { solve w before k; }   // illegal: k is randc
endclass

module test_illegal_solve_before_randc_ordered_after;
  sbr_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
