/*
:name: test_vpi_assertion_callbacks_preserved_and_installed_while_stopped
:description: Suspending assertions preserves callbacks and accepts new registrations for resumed attempts
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.1 39.4.2 39.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_callbacks_preserved_and_installed_while_stopped.expected
:vpi_c: @test_vpi_assertion_callbacks_preserved_and_installed_while_stopped.c
*/
`timescale 1ns/1ns
module test_vpi_assertion_callbacks_preserved_and_installed_while_stopped;
  bit clk, armed = 1, outcome;
  int failure_actions = 0;

  good: assert property (@(posedge clk) armed |-> ##2 outcome);
  bad: assert property (@(posedge clk) armed |-> ##2 !outcome)
    else failure_actions++;

  always #5 clk = ~clk;
  initial begin
    #1 $vt_place_callbacks(0);
    #9 $vt_assertion_system_switch(0);
    #10 begin
      armed = 0;
      outcome = 1;
    end
    #7 $vt_place_callbacks(1);
    #1 $vt_report_callbacks;
    #2 begin
      $vt_assertion_system_switch(1);
      armed = 1;
    end
    #10 armed = 0;
    #16 $vt_report_callbacks;
    $display("failure actions=%0d", failure_actions);
    $finish(0);
  end
endmodule
