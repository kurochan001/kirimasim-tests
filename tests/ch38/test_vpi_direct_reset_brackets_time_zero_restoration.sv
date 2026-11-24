/*
:name: test_vpi_direct_reset_brackets_time_zero_restoration
:description: A direct reset triggers both callbacks around time-zero restoration
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 D.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_direct_reset_brackets_time_zero_restoration.expected
:expected_exit: 0
:vpi_c: @test_vpi_direct_reset_brackets_time_zero_restoration.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_direct_reset_brackets_time_zero_restoration;
  `include "request_restore_once.svh"

  int state = 23;
  wire [7:0] mirrored_state = 8'(state);

  initial begin
    if ($reset_count == 0) begin
      if (!first_restore_request()) $fatal(1, "reset did not advance the count");
      #5 state = 52;
      #1 $reset(1, 43, 0);
      $display("unexpected return to the original initial block");
    end
    else begin
      $display("initial t=%0d state=%0d net=%0d reset count=%0d reset value=%0d",
               $time, state, mirrored_state, $reset_count, $reset_value);
      #1 $finish(0);
    end
  end

  initial #20 $finish(1);
endmodule
