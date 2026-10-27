/*
:name: test_35_rest_deprecated_dpi_diagnostic
:description: An import declaration that uses the deprecated "DPI" version string is rejected at compile time with an error that names "DPI-C" as its replacement (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the import declaration uses the deprecated DPI version string "DPI"
:expected_stderr_regex: test_35_rest_deprecated_dpi_diagnostic\.sv:26:
*/
// IEEE 1800-2023 §35.5.4: the dpi_spec_string of an import declaration can be
// "DPI-C" or the deprecated "DPI"; use of "DPI" shall generate a compile-time
// warning or error that says it is deprecated and should be replaced with
// "DPI-C". §35.4 gives the same deprecation for the version string.
//
// The import below uses "DPI". The tool Verilator 5.052 rejects it with an
// error whose text names "DPI-C" as the replacement, so the deprecation is
// reported at compile time. The message does not repeat the standard's advice
// that moving to "DPI-C" can require changes in the C application; that part
// of the sentence is not observed by this test.

module test_35_rest_deprecated_dpi_diagnostic;
  import "DPI" function int c_legacy_add(input int a);   // deprecated string

  initial $display("%0d", c_legacy_add(1));
endmodule
