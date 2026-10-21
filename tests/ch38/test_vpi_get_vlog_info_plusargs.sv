/*
:name: test_vpi_get_vlog_info_plusargs
:description: The argv array that vpi_get_vlog_info returns holds argc strings, among them the plusargs of the invocation in the order given, which the design reads too (IEEE 1800-2023 Section 38.17)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.17 21.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +vt_alpha +vt_count=3
:vpi_c: @test_vpi_get_vlog_info_plusargs.c
:expected_stdout: @test_vpi_get_vlog_info_plusargs.expected
*/
// IEEE 1800-2023 §38.17: vpi_get_vlog_info gives the number of invocation
// options, argc, and argv, an array of argc pointers to the strings of the
// tool's command line, the first being the tool's name. The simulation is run
// with the plusargs +vt_alpha and +vt_count=3, which the application looks for
// in argv at the start of the simulation. Which other options are there
// depends on the tool, so only the plusargs and their order are printed. The
// design reads the same plusargs with $test$plusargs and $value$plusargs
// (21.6).

module test_vpi_get_vlog_info_plusargs;
  int count;

  initial begin
    #1;
    if ($test$plusargs("vt_alpha") && $value$plusargs("vt_count=%d", count))
      $display("design: vt_alpha given, vt_count=%0d", count);
  end
endmodule
