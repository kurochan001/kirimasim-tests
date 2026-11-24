/*
:name: test_dpi_import_task_rejects_wrong_status_after_disable
:description: An imported task reports a fatal protocol violation when it returns normal status after a disable
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_import_task_rejects_wrong_status_after_disable.expected
:dpi_c: @test_dpi_import_task_rejects_wrong_status_after_disable.c
:expected_stderr_regex: (?im)^(?=[^\n]*(?:fatal|error))(?=[^\n]*\b(?:dpi|import)\b)(?=[^\n]*disabl)(?=[^\n]*(?:status|return|acknowledg|protocol))[^\n]+
*/
`timescale 1ns/1ns
module test_dpi_import_task_rejects_wrong_status_after_disable;
  import "DPI-C" context task observed_import(input int mode);
  export "DPI-C" task waiter_from_c;
  export "DPI-C" function forbidden_export;

  task waiter_from_c(input int wait_units);
    #(wait_units);
    $display("%0d: exported task reached its end", $time);
  endtask

  function int forbidden_export();
    $display("%0d: forbidden export ran", $time);
    return 17;
  endfunction

  initial begin : worker
    $display("%0d: entering the imported task", $time);
    observed_import(0);
    $display("%0d: worker continued", $time);
  end

  initial begin
    #5 disable worker;
    #20 $display("%0d: later unrelated process", $time);
  end
endmodule
