/*
:name: test_evcd_diagnoses_directory_used_as_output_filename
:description: Extended VCD dumping diagnoses an existing directory used as the output filename
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_diagnoses_directory_used_as_output_filename.expected
:expected_stderr_regex: (?im)^(?=[^\n]*(?:error|warning))(?=[^\n]*(?:dumpports|evcd))(?=[^\n]*(?:cannot open|failed to open|could not open|directory|unable to open))[^\n]+
*/
`timescale 1ns/1ns
module evcd_directory_probe(input wire signal_pin);
endmodule

module test_evcd_diagnoses_directory_used_as_output_filename;
  logic value = 0;
  evcd_directory_probe dut(value);

  initial begin
    $display("opening an extended dump");
    $dumpports(dut, ".");
    #1 value = 1;
    #1 $finish(0);
  end
endmodule
