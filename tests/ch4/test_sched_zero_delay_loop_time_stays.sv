/*
:name: test_sched_zero_delay_loop_time_stays
:description: A loop of #0 delays stays in one time step: $time does not advance however many times it runs (IEEE 1800-2023 Section 4.4.2.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.3 4.5 9.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_zero_delay_loop_time_stays.expected
*/
// IEEE 1800-2023 §9.4.1: #0 suspends the process and resumes it in the Inactive
// region of the same time step (§4.4.2.3); simulation time advances only when
// every region of the step is empty (§4.5). After 100 zero delays the time is
// still 0.

`timescale 1ns/1ns

module test_sched_zero_delay_loop_time_stays;
  int count = 0;
  initial begin
    repeat (100) begin
      #0 count++;
    end
    $display("count=%0d at %0t", count, $time);
    #1 $display("one delay later at %0t", $time);
  end
endmodule
