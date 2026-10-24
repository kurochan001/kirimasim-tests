/*
:name: test_illegal_directive_split_across_lines
:description: A compiler directive that is not specified as multiline has to be on one line, so a `timescale whose precision is on the next line is an error (IEEE 1800-2023 Section 22.2)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.2 22.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the `timescale directive is split over two lines; on its own line it lacks the time precision, and the next line is not a valid language element
:expected_stderr_regex: test_illegal_directive_split_across_lines\.sv:(23|24):
*/
// IEEE 1800-2023 §22.2: unless a directive is specified as supporting
// multiple lines, it shall be all on one line; `timescale is not such a
// directive (§22.7 gives it a time unit and a time precision). The
// directive below ends at the end of its line without its precision, and
// the rest, on the next line, is not a language element. A tool can report
// either line.
// Icarus Verilog 13.0 reads the precision from the next line and accepts
// the design.

`timescale 1ns  // illegal: the directive ends here
  / 1ps  // or here

module test_illegal_directive_split_across_lines;
  initial #1 $display("done");
endmodule
