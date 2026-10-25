/*
:name: test_illegal_include_absolute_path_in_angle_brackets
:description: When the file name of `include is an absolute path, only the double quote form can be used, so `include </dev/null> is an error while `include "/dev/null" is legal (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the absolute path /dev/null is given to `include in angle brackets, and an absolute path can only be used with the double quote form
:expected_stderr_regex: test_illegal_include_absolute_path_in_angle_brackets\.sv:29:
*/
// IEEE 1800-2023 §22.4: when the file name of an `include is an absolute
// path, only that file is included and only the double quote form of the
// directive can be used. The test needs an absolute path to a file that
// exists wherever it runs, and uses /dev/null, the empty file that every
// POSIX system has: the first `include, in double quotes, is legal and adds
// no text; the second gives the same absolute path in angle brackets, and
// it is the only error. A tool that accepted the angle bracket form for an
// absolute path would include the same empty file and accept the design.
// Icarus Verilog 13.0 rejects the second line because it does not support
// the angle bracket form at all, so its error does not come from this
// rule. The design is accepted by Verilator 5.052.

module test_illegal_include_absolute_path_in_angle_brackets;
  logic a = 1'b0;
  `include "/dev/null"
  `include </dev/null>  // illegal: absolute path in angle brackets
  logic b = 1'b1;
endmodule
