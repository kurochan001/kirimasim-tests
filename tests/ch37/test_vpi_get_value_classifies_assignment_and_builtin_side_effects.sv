/*
:name: test_vpi_get_value_classifies_assignment_and_builtin_side_effects
:description: Reading a VPI expression twice repeats assignment, increment, user call, method and file read effects
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_side_effects.c
:expected_stdout: @test_vpi_get_value_classifies_assignment_and_builtin_side_effects.expected
*/
module test_vpi_get_value_classifies_assignment_and_builtin_side_effects;
  int direct_value = 2;
  int nested_value = 3;
  int steps = 7;
  int calls = 0;
  int cursor = 0;
  int entries [3] = '{41, 52, 63};
  int data_queue[$] = '{17, 28, 39};
  int input_file;

  function automatic int changing_call();
    calls++;
    return calls;
  endfunction

  function automatic int add_sixty(input int value);
    return 60 + value;
  endfunction

  initial begin
    $vt_twice((direct_value += 3));
    $display("assignment state=%0d", direct_value);
    $vt_twice(--steps);
    $display("decrement state=%0d", steps);
    $vt_twice(100 + (nested_value *= 2));
    $display("operand state=%0d", nested_value);
    $vt_twice(add_sixty(changing_call()));
    $display("nested call count=%0d", calls);
    $vt_twice(entries[cursor++]);
    $display("index state=%0d", cursor);
    $vt_twice(data_queue.pop_front());
    $display("queue size=%0d front=%0d", data_queue.size(), data_queue[0]);
    input_file = $fopen("vpi-effect-characters.bin", "wb");
    $fwrite(input_file, "AB");
    $fclose(input_file);
    input_file = $fopen("vpi-effect-characters.bin", "rb");
    $vt_twice($fgetc(input_file));
    $display("file position=%0d", $ftell(input_file));
    $fclose(input_file);
  end
endmodule
