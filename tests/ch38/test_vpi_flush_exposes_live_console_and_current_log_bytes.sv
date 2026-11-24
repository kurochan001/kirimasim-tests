/*
:name: test_vpi_flush_exposes_live_console_and_current_log_bytes
:description: VPI flush makes a partial line visible in the output channel and active log before shutdown
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.5 38.30
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_flush_exposes_live_console_and_current_log_bytes.expected
:vpi_c: @test_vpi_flush_exposes_live_console_and_current_log_bytes.c
:args: --logfile active-vpi.log
*/
module test_vpi_flush_exposes_live_console_and_current_log_bytes;
  initial begin
    $display("flush probe started");
    $vt_flush_observe;
    $display("simulation remains active");
  end
endmodule
