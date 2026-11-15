/*
:name: test_illegal_cg_cross_function_other_cross
:description: a cross bin calls a function declared in another cross of the same covergroup (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin b2 of the cross x2 calls one, which is declared in the cross x1 and is not visible outside it
:expected_stderr_regex: test_illegal_cg_cross_function_other_cross\.sv:40:
*/
// IEEE 1800-2023 §19.6: a function declared within a cross is not visible
// outside that cross. The cross x1 declares one, an automatic function that
// returns 1 and reads nothing else, and its bin b1 calls it in its intersect
// list, which is legal. The cross x2 is a sibling scope of x1 in the same
// covergroup, and its bin b2 calls one in the same way; no other function of
// that name exists, so that call is the one error. With the function
// declared in x2 as well, or b2 removed, the design is legal.
//
// Icarus Verilog 13.0 does not implement covergroups, and the 5.054
// release of Verilator does not find one from the legal call in x1 either,
// so neither error is evidence for the rule. The cited clause alone decides
// this test.

module test_illegal_cg_cross_function_other_cross;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a;
    cb: coverpoint b;
    x1: cross ca, cb {
      function automatic int one();
        return 1;
      endfunction
      bins b1 = binsof(ca) intersect {one()};
    }
    x2: cross ca, cb {
      bins b2 = binsof(cb) intersect {one()};   // illegal: one is local to x1
    }
  endgroup

  cg g = new;

  initial $display("not reached");
endmodule
