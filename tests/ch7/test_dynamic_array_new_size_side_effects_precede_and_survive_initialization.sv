/*
:name: test_dynamic_array_new_size_side_effects_precede_and_survive_initialization
:description: A dynamic array initializer observes the size expression's changes and cannot retroactively alter the converted extent
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 6.11.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_dynamic_array_new_size_side_effects_precede_and_survive_initialization.expected
*/
module test_dynamic_array_new_size_side_effects_precede_and_survive_initialization;
  typedef int int_array_t[];
  int_array_t data, source;
  bit [95:0] requested = {32'h4321_a987, 64'd3};
  int order = 0;

  function automatic bit [95:0] extent();
    order = order * 10 + 1;
    source[0] = 42;
    return requested;
  endfunction

  function automatic int_array_t initialization();
    order = order * 10 + 2;
    requested[63:0] = 1;
    return source;
  endfunction

  initial begin
    source = new[2];
    source[0] = 21;
    source[1] = 53;
    data = new[extent()](initialization());
    $display("calls=%0d requested now=%0d size=%0d contents=%0d %0d %0d",
             order, requested[63:0], data.size(), data[0], data[1], data[2]);
  end
endmodule
