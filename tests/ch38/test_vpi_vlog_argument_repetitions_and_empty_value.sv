/*
:name: test_vpi_vlog_argument_repetitions_and_empty_value
:description: VPI preserves duplicate plus arguments and the empty value in the invocation argument list
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.17 21.6
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_vlog_argument_repetitions_and_empty_value.expected
:vpi_c: @test_vpi_vlog_argument_repetitions_and_empty_value.c
:args: +vt_level=alpha +vt_empty= +vt_level=alpha
*/
module test_vpi_vlog_argument_repetitions_and_empty_value;
  string value;

  initial begin
    #1;
    if ($value$plusargs("vt_level=%s", value))
      $display("first_level=%s", value);
    else
      $display("missing vt_level");
  end
endmodule
