/*
:name: test_vpi_deprecated_interface_iteration_matches_current_handles
:description: The deprecated interface declaration iterator and current virtual interface iterator return the same scalar and array member objects
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 25.9 C.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_deprecated_interface_iteration_matches_current_handles.c
:expected_stdout: @test_vpi_deprecated_interface_iteration_matches_current_handles.expected
*/
interface legacy_iter_link;
  logic [7:0] payload;
endinterface

module test_vpi_deprecated_interface_iteration_matches_current_handles;
  legacy_iter_link first();
  legacy_iter_link second();
  virtual legacy_iter_link chosen;
  virtual legacy_iter_link links [3:4];

  initial begin
    first.payload = 8'h17;
    second.payload = 8'h29;
    chosen = first;
    links[3] = second;
    links[4] = first;
    #1 $probe_interface_iterators;
    $display("design=%h/%h/%h", chosen.payload, links[3].payload, links[4].payload);
  end
endmodule
