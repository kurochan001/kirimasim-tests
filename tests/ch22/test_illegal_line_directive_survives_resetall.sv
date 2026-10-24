/*
:name: test_illegal_line_directive_survives_resetall
:description: The results of `line are not affected by `resetall, so after `line 700 with an absolute file name and a `resetall on the next line, an error two lines later is still reported at line 702 of that file (IEEE 1800-2023 Section 22.12)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.12
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable c that the initial procedure assigns is not declared
:expected_stderr_regex: /orig_src/line_after_resetall\.sv:702:
*/
// IEEE 1800-2023 §22.12: the results of the `line directive are not
// affected by `resetall, and its file name can be a full path name. The
// `line below names the absolute path /orig_src/line_after_resetall.sv, so
// the `resetall on the following line is line 700 of that file, the module
// header line 701, and the assignment of the undeclared variable c line 702.
// That assignment is the only error. A tool whose `resetall restored the
// real file name and line number would report it at the line of this file.

`line 700 "/orig_src/line_after_resetall.sv" 0
`resetall
module test_illegal_line_directive_survives_resetall;
  initial c = 1'b1;  // illegal: c is not declared
endmodule
