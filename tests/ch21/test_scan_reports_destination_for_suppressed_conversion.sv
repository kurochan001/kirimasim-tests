/*
:name: test_scan_reports_destination_for_suppressed_conversion
:description: A scan reports an extra destination when its only conversion suppresses assignment
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scan_reports_destination_for_suppressed_conversion.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*\$?sscanf\b)(?=[^\n]*(?:\bargument|\bdestination|\bsuppress))[^\n]+
*/
`timescale 1ns/1ns
module test_scan_reports_destination_for_suppressed_conversion;
  int unused_destination = 41;

  initial begin
    #1 $display("scan invoked");
    void'($sscanf("73", "%*d", unused_destination));
  end
endmodule
