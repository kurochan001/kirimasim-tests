/*
:name: test_line_directive
:description: `line sets the line number and file name of the following line, as seen by `__LINE__ and `__FILE__ (IEEE 1800-2023 Section 22.12)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.12 22.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_line_directive.expected
*/
// IEEE 1800-2023 §22.12: `line number "file" level gives the line that follows
// it that line number and file name, and counting continues from there.
// §22.13: `__LINE__ expands to the current line number and `__FILE__ to the
// current file name as a string literal, so both show the values set by
// `line.

module test_line_directive;
  initial begin
`line 500 "renamed_source.sv" 0
    $display("line=%0d file=%s", `__LINE__, `__FILE__);
    $display("next line=%0d", `__LINE__);
  end
endmodule
