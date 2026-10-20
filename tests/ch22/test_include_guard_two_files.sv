/*
:name: test_include_guard_two_files
:description: Two source files that include the same guarded file both see its macro, whether the files form one compilation unit or two (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4 22.5.1 3.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_guard_two_files.svh include_guard_two_files_helper.sv
:expected_stdout: @test_include_guard_two_files.expected
*/
// IEEE 1800-2023 §22.4, §3.12.1: the helper file and this file both include
// a file that defines a macro inside a guard. If the two files form one
// compilation unit, the second `include is skipped and the macro defined by
// the first is still in effect (22.5.1); if they are separate units, each
// includes the file anew. Either way both files see the macro, which is why
// the test does not depend on how the tool forms compilation units.

`include "include_guard_two_files.svh"

module test_include_guard_two_files;
  int y;

  include_guard_two_files_helper h(.x(3), .y(y));

  initial #1 $display("helper=%0d here=%0d", y, 3 * `INCLUDE_GUARD_TWO_FILES_SCALE);
endmodule
