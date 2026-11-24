/*
:name: test_virtual_interface_event_control_inside_always_begin_end
:description: An event control in an always block body can wait on a virtual interface signal
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 9.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_event_control_inside_always_begin_end.expected
*/
interface procedural_event;
  bit clock;
endinterface

module test_virtual_interface_event_control_inside_always_begin_end;
  procedural_event source();
  virtual procedural_event selected = source;
  int body_events = 0, initial_events = 0;

  always begin
    @(posedge selected.clock);
    body_events++;
  end

  initial begin
    repeat (2) begin
      @(posedge selected.clock);
      initial_events++;
    end
  end

  initial begin
    #4 source.clock = 1;
    #1 $display("first always=%0d initial=%0d", body_events, initial_events);
    #4 source.clock = 0;
    #1 $display("fall always=%0d initial=%0d", body_events, initial_events);
    #4 source.clock = 1;
    #1 $display("second always=%0d initial=%0d", body_events, initial_events);
  end
endmodule
