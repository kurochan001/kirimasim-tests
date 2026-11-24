/*
:name: test_dpi_context_task_does_not_authorize_noncontext_child_import
:description: A task running inside a DPI context cannot give an ordinary child import export permissions
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_context_task_does_not_authorize_noncontext_child_import.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal|invalid|illegal)\b)(?=[^\n]*(?:dpi|export))(?=[^\n]*(?:non.?context|requires? (?:a )?context|context required))[^\n]+
:dpi_c: @test_dpi_context_task_does_not_authorize_noncontext_child_import.c
:expected_exit: nonzero
*/
`timescale 1ns/1ns
module test_dpi_context_task_does_not_authorize_noncontext_child_import;
  import "DPI-C" context task enter_sv_task(input bit use_ordinary, input int tag);
  import "DPI-C" context function int child_context(input int tag);
  import "DPI-C" function int child_ordinary(input int tag);
  export "DPI-C" task sv_tick_task;
  export "DPI-C" function sv_reentry;

  function automatic int sv_reentry(int tag);
    $display("export tag=%0d at=%0t", tag, $time);
    return tag + 100;
  endfunction

  task automatic sv_tick_task(input bit use_ordinary, input int tag);
    int returned;
    #2;
    if (use_ordinary)
      returned = child_ordinary(tag);
    else
      returned = child_context(tag);
    $display("task returned=%0d", returned);
  endtask

  initial begin
    enter_sv_task(0, 7);
    $display("request from noncontext child");
    enter_sv_task(1, 9);
    $display("unexpected return from noncontext child");
  end
endmodule
