/*
:name: test_illegal_typed_constructor_shallow_copy
:description: a typed constructor call cannot be used for a shallow copy (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.12 8.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the shallow copy of p1 is written as a typed constructor call pkt_c::new p1
:expected_stderr_regex: test_illegal_typed_constructor_shallow_copy\.sv:29:
*/
// IEEE 1800-2023 §8.12: it shall be illegal to use a typed constructor call
// (8.8) for a shallow copy. new p1 is a legal shallow copy and pkt_c::new a
// legal typed constructor call; pkt_c::new p1 combines them.

class pkt_c;
  int v = 3;
endclass

module test_illegal_typed_constructor_shallow_copy;
  pkt_c p1, p2, p3, p4;

  initial begin
    p1 = new;
    p2 = new p1;
    p3 = pkt_c::new;
    p4 = pkt_c::new p1;   // illegal: typed constructor call as a shallow copy
    $display("%0d %0d", p2.v, p3.v);
  end
endmodule
