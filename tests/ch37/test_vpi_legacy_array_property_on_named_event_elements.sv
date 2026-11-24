/*
:name: test_vpi_legacy_array_property_on_named_event_elements
:description: The deprecated VPI array property distinguishes event array elements from a standalone event
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.27
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_legacy_array_property_on_named_event_elements.expected
:expected_exit: 0
:vpi_c: @test_vpi_legacy_array_property_on_named_event_elements.c
*/
module test_vpi_legacy_array_property_on_named_event_elements;
  event standalone;
  event events [-2:-1];

  initial begin
    -> standalone;
    -> events[-1];
    #1 $probe_array_events;
  end
endmodule
