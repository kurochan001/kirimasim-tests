/*
:name: test_vpi_reads_keep_staged_indices_and_arguments_stable
:description: Staging state changes before using an index or call argument keeps repeated VPI reads stable
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_side_effects.c
:expected_stdout: @test_vpi_reads_keep_staged_indices_and_arguments_stable.expected
*/
module test_vpi_reads_keep_staged_indices_and_arguments_stable;
  int entries [0:2];
  int cursor = 0;
  int value_calls = 0;
  int saved_index, task_arg, call_arg, user_result, system_result;

  function automatic int next_value();
    value_calls++;
    return value_calls == 1 ? 8 : 16;
  endfunction

  function automatic int add_five(input int value);
    return value + 5;
  endfunction

  initial begin
    entries[0] = 41;
    entries[1] = 52;
    entries[2] = 63;
    saved_index = cursor;
    cursor++;
    $vt_twice(entries[saved_index]);
    $display("staged index cursor=%0d", cursor);

    task_arg = next_value();
    $vt_twice(task_arg);
    $display("staged task calls=%0d", value_calls);

    call_arg = next_value();
    user_result = add_five(call_arg);
    system_result = $clog2(call_arg);
    $vt_twice(user_result);
    $vt_twice(system_result);
    $display("staged function calls=%0d", value_calls);
  end
endmodule
