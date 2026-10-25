/*
:name: test_blocking_assignment_sequential_not_parallel
:description: a blocking assignment completes before the next statement of its sequential block runs, also when it has an intra-assignment delay, while the other branches of a fork run on in the meantime (IEEE 1800-2023 Section 10.4.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_blocking_assignment_sequential_not_parallel.expected
*/
// IEEE 1800-2023 §10.4.1: a blocking assignment shall be executed before the
// statements that follow it in a sequential block, but it does not prevent
// statements in a parallel block from executing.
//
// The first branch of the fork assigns a = 1 and reads it in the next
// statement, then makes the blocking assignment b = #5 a + 10 (read at 0,
// written at 5) and reads b in the statement after it, which therefore runs
// at time 5 and sees 11. The second branch is not held up by the first: it
// runs at time 0 and at time 2, while the first branch is still blocked,
// and at time 2 sees b still 0.

`timescale 1ns/1ns
module test_blocking_assignment_sequential_not_parallel;
  int a = 0, b = 0, c, t_b = -1;
  int seen_at0 = -1, seen_at2_b = -1, t_second = -1;

  initial begin
    fork
      begin
        a = 1;
        c = a;
        b = #5 a + 10;
        t_b = $time;
      end
      begin
        seen_at0 = $time;
        #2 seen_at2_b = b;
        t_second = $time;
      end
    join
    $display("first branch: c=%0d, b=%0d, statement after b ran at t=%0d", c, b, t_b);
    $display("second branch: ran at t=%0d, saw b=%0d at t=%0d", seen_at0, seen_at2_b, t_second);
  end
endmodule
