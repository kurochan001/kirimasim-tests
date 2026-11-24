/*
:name: test_vpi_printf_reports_formatted_length_and_encoding_error
:description: VPI printf writes to both channels and returns EOF when the C encoding fails
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.30 38.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_printf_reports_formatted_length_and_encoding_error.expected
:vpi_c: @test_vpi_printf_reports_formatted_length_and_encoding_error.c
:args: --logfile format-vpi.log
*/
module test_vpi_printf_reports_formatted_length_and_encoding_error;
  initial begin
    $vt_check_print;
    $display("printf check completed");
  end
endmodule
