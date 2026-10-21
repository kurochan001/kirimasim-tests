/*
:name: test_sched_wait_counts_nonblocking_steps
:description: A wait statement resumes in the time step where a series of nonblocking updates first makes its condition true (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.4.3 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_wait_counts_nonblocking_steps.expected
*/
// IEEE 1800-2023 §9.4.3: wait evaluates its condition again when a variable in
// it changes, and resumes once it is true. count is incremented with a
// nonblocking assignment at times 1, 2 and 3 (§4.4.2.4), so the condition count
// == 3 first holds in the time step of time 3.

`timescale 1ns/1ns

module test_sched_wait_counts_nonblocking_steps;
  int count = 0;
  initial begin
    wait (count == 3);
    $display("count=%0d at %0t", count, $time);
  end
  initial begin
    repeat (4) #1 count <= count + 1;
  end
endmodule
