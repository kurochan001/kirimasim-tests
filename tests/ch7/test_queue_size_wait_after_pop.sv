/*
:name: test_queue_size_wait_after_pop
:description: Queue size changes unblock a wait when a pop makes the queue empty (IEEE 1800-2023 Section 7.10.2.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_size_wait_after_pop.expected
*/
// IEEE 1800-2023 7.10.2.7: Size is a dynamic method result whose change must
// wake a blocked condition; an unchanged size must not complete the wait.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output.

module test_queue_size_wait_after_pop;
  int q[$] = '{1, 2};
  bit empty_seen;
  int value;
  initial begin wait(q.size() == 0); empty_seen = 1; end
  initial begin
    #1 value = q.pop_front();
    #1 $display("one_left=%0d woke=%0d", q.size(), empty_seen);
    value = q.pop_back();
    #1 $display("empty=%0d woke=%0d", q.size(), empty_seen);
  end
endmodule
