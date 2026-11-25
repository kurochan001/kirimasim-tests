/*
:name: test_dpi_context_and_noncontext_access_in_two_instances
:description: Context imports see recent module stores while ordinary imports update only their arguments
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_and_noncontext_access_in_two_instances.c
:expected_stdout: @test_dpi_context_and_noncontext_access_in_two_instances.expected
*/
module dpi_access_cell;
  import "DPI-C" context function int h65_context(input int delta);
  import "DPI-C" function int h65_arguments(input int item, inout int count);
  export "DPI-C" function h65_read_cell;
  export "DPI-C" function h65_write_cell;

  int state;

  function int h65_read_cell();
    return state;
  endfunction

  function void h65_write_cell(input int next_state);
    state = next_state;
  endfunction

  task automatic exercise(input int seed, input int delta);
    int old_state, output_value;
    int count = delta + 20;
    state = seed;
    old_state = h65_context(delta);
    $display("context before=%0d after=%0d", old_state, state);
    output_value = h65_arguments(seed, count);
    $display("ordinary result=%0d count=%0d state=%0d", output_value, count, state);
  endtask
endmodule

module test_dpi_context_and_noncontext_access_in_two_instances;
  dpi_access_cell left();
  dpi_access_cell right();

  initial begin
    left.exercise(17, 3);
    right.exercise(33, 4);
    left.exercise(27, 8);
    $display("instance state left=%0d right=%0d", left.state, right.state);
  end
endmodule
