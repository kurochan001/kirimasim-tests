/*
:name: test_dpi_nested_import_function_cannot_enable_export_task
:description: An imported function cannot enable an exported task through a nested context call
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.8 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_nested_import_function_cannot_enable_export_task.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:fatal|error|invalid|illegal)\b)(?=[^\n]*(?:DPI|export))(?=[^\n]*(?:sv_task_nested|task))(?=[^\n]*function)[^\n]+
:dpi_c: @test_dpi_nested_import_function_cannot_enable_export_task.c
:expected_exit: nonzero
*/
module test_dpi_nested_import_function_cannot_enable_export_task;
  import "DPI-C" context function int first_entry(input int tag, input bit use_task);
  import "DPI-C" context function int second_entry(input int tag, input bit use_task);
  export "DPI-C" function sv_bridge_nested;
  export "DPI-C" function sv_function_nested;
  export "DPI-C" task sv_task_nested;

  function automatic int sv_bridge_nested(int tag, bit use_task);
    return second_entry(tag, use_task);
  endfunction

  function automatic int sv_function_nested(int tag);
    return tag + 40;
  endfunction

  task automatic sv_task_nested(int tag);
    $display("forbidden task executed tag=%0d", tag);
  endtask

  initial begin
    int result;
    result = first_entry(2, 0);
    $display("nested function returned=%0d", result);
    $display("requesting task from nested import");
    result = first_entry(7, 1);
    $display("unexpected task status=%0d", result);
  end
endmodule
