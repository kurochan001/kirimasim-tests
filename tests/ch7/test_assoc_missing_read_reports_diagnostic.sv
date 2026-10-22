/*
:name: test_assoc_missing_read_reports_diagnostic
:description: A missing read returns the four-state default with a warning and no allocation (IEEE 1800-2023 Section 7.8.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.6 7.4.5 7.9.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_missing_read_reports_diagnostic.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// Only the missing read requires a warning. Check raw messages and values;
// no implementation-specific diagnostic wording or line format is required.

module test_assoc_missing_read_reports_diagnostic;
  integer a[int];
  integer result;
  initial begin
    a[2] = 17;
    result = a[99];
    $display("missing=%h size=%0d present=%0d absent=%0d",
             result, a.num(), a[2], a.exists(99));
  end
endmodule
