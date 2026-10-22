/*
:name: test_program_renba_after_zero_delay
:description: A program NBA update is still pending after a zero delay but visible after time advances (IEEE 1800-2023 Section 4.4.2.8)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.8 4.4.2.7 24.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_renba_after_zero_delay.expected
*/
// IEEE 1800-2023 4.4.2.8 4.4.2.7 24.3.1: The program resumes in Re-Inactive
// before the Re-NBA update. A later nonzero delay observes the completed
// update.

program test_program_renba_after_zero_delay;
  int value = 0;
  initial begin
    #1 value <= 7;
    #0 $display("before_update=%0d", value);
    #1 $display("after_update=%0d", value);
  end
endprogram
