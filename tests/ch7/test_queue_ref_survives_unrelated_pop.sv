/*
:name: test_queue_ref_survives_unrelated_pop
:description: Popping the last queue element preserves a reference to the first element (IEEE 1800-2023 Section 7.10.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.3 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_ref_survives_unrelated_pop.expected
*/
// IEEE 1800-2023 7.10.3 13.5.2: A method removing another element must preserve
// the referenced element, even after push_front changes its numeric index.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

`timescale 1ns/1ns
module test_queue_ref_survives_unrelated_pop;
  int q[$] = '{4, 8, 12};
  int popped;
  task automatic update(ref int r);
    #3 r = 99;
  endtask
  initial begin
    fork update(q[0]); join_none
    #1 popped = q.pop_back();
    q.push_front(2);
    #3 $display("popped=%0d queue=%0d,%0d,%0d", popped, q[0], q[1], q[2]);
  end
endmodule
