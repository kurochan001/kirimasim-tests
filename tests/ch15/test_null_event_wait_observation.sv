/*
:name: test_null_event_wait_observation
:description: A live event wakes its waiter and separate null waits expose their observed behavior
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_null_event_wait_observation.expected
*/
`timescale 1ns/1ns
module test_null_event_wait_observation;
  event pulse;
`ifdef OBSERVE_NULL_WAIT
  event nothing = null;
`endif
  bit reached;

  initial begin
    fork
      begin @pulse; reached = 1; end
    join_none
    #2 -> pulse;
    #1 $display("live wait reached=%0d", reached);
`ifdef OBSERVE_NULL_WAIT
    if ($test$plusargs("observe_null_event")) begin
      fork
        begin
          $display("before null event control");
          @nothing;
          $display("null event control returned");
        end
      join_none
    end
    if ($test$plusargs("observe_null_triggered")) begin
      fork
        begin
          $display("before null triggered wait");
          wait (nothing.triggered);
          $display("null triggered wait returned");
        end
      join_none
    end
`endif
    #3 $display("independent process t=%0d", $time);
    $finish(0);
  end
endmodule
