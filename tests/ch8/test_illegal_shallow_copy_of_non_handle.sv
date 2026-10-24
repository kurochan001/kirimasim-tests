/*
:name: test_illegal_shallow_copy_of_non_handle
:description: the expression after new in a shallow copy has to be an object handle (IEEE 1800-2023 Section 8.8)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.8 8.12
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the shallow copy new k copies the int variable k, which is not an object handle
:expected_stderr_regex: test_illegal_shallow_copy_of_non_handle\.sv:29:
*/
// IEEE 1800-2023 §8.8: in the form new expression, a shallow copy (8.12), the
// expression shall evaluate to an object handle. new p1 copies the object of
// p1 and is legal; new k names an int variable.

class pkt_c;
  int v = 3;
endclass

module test_illegal_shallow_copy_of_non_handle;
  pkt_c p1, p2, p3;
  int k = 5;

  initial begin
    p1 = new;
    p2 = new p1;
    p3 = new k;   // illegal: k is not an object handle
    $display("%0d", p2.v);
  end
endmodule
