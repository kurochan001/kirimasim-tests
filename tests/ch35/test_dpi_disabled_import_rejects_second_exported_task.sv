/*
:name: test_dpi_disabled_import_rejects_second_exported_task
:description: A disabled imported task cannot enable a second exported task even if it would return immediately
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9 35.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_disabled_import_rejects_second_exported_task.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:fatal|error)\b)(?=[^\n]*(?:dpi|export))(?=[^\n]*disabl)(?=[^\n]*(?:cannot|after|prohibit|while|protocol))[^\n]+
:dpi_c: @test_dpi_disabled_import_rejects_second_exported_task.c
:expected_exit: nonzero
*/
`timescale 1ns/1ns
module test_dpi_disabled_import_rejects_second_exported_task;
  import "DPI-C" context task observe_disable(input int tag);
  export "DPI-C" task wait_before_return;
  export "DPI-C" task finish_immediately;

  task automatic wait_before_return(input int tag);
    #10 $display("unexpected timed return tag=%0d", tag);
  endtask

  task automatic finish_immediately(input int tag);
    $display("unexpected second task tag=%0d", tag);
  endtask

  initial begin : active_chain
    $display("entering import");
    observe_disable(67);
    $display("unexpected disabled block continuation");
  end

  initial begin
    #3 disable active_chain;
    #20 $display("unexpected continuation after protocol violation");
  end
endmodule
