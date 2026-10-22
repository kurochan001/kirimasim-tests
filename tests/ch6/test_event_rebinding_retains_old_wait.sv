/*
:name: test_event_rebinding_retains_old_wait
:description: Rebinding an event variable does not retarget a process already blocked on its old synchronization object (IEEE 1800-2023 Section 6.17)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.17 15.5.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_rebinding_retains_old_wait.expected
*/
// IEEE 1800-2023 6.17 15.5.5.1: A blocked event control keeps the object
// selected when it started; reassigning its handle affects only later event
// controls.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

`timescale 1ns/1ns
module test_event_rebinding_retains_old_wait;
  event original, other;
  event selected = original;
  bit woke;
  initial begin
    fork
      begin @(selected); woke = 1; end
    join_none
    #1 selected = other;
    -> other;
    #1 $display("other_woke=%0d", woke);
    -> original;
    #1 $display("original_woke=%0d bound_to_other=%0d", woke, selected == other);
  end
endmodule
