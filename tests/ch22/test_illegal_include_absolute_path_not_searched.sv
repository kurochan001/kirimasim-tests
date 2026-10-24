/*
:name: test_illegal_include_absolute_path_not_searched
:description: When the file name of `include is an absolute path, only that file is included, so an absolute path to a directory that does not exist is an error even though a file of the same name is in an include directory (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_absolute_only_helper.svh
:should_fail_because: the absolute path of the second `include names a file in a directory that does not exist, and an absolute path is not searched for in the include directories
:expected_stderr_regex: test_illegal_include_absolute_path_not_searched\.sv:30:
*/
// IEEE 1800-2023 §22.4: when the file name of an `include is an absolute
// path, only that file name is included; the current working directory and
// the user-specified locations are searched only for a relative path in
// double quotes. The file that :files: names is
// include_absolute_only_helper.svh, and its directory is an include
// directory: the first `include names it by the relative path and is legal.
// The second `include gives an absolute path that ends in the same file
// name, in a directory that does not exist, and is the only error. A tool
// that looked for the last part of an absolute path in the include
// directories would find the helper again, which a guard makes add nothing
// the second time, and accept the design.

module test_illegal_include_absolute_path_not_searched;
  `include "include_absolute_only_helper.svh"
  localparam int B = INCLUDE_ABSOLUTE_ONLY_A + 1;
  `include "/kirimasim_no_such_dir/include_absolute_only_helper.svh"  // illegal: no such file
  initial $display("B=%0d", B);
endmodule
