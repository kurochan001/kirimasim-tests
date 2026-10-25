/*
:name: test_file_line_across_include
:description: `__FILE__ expands to the path by which the tool opened the current file, for an included file the path through its include directory, and `__LINE__ to the current line, counted from 1 in an included file; after the `include, both return to the including file, at the line after the `include (IEEE 1800-2023 Section 22.13)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.13 22.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:incdirs: include_loc_ch22
:expected_stdout: @test_file_line_across_include.expected
*/
// IEEE 1800-2023 §22.13: `__FILE__ expands to a string literal with the name
// of the current input file, the path by which the tool opened it rather than
// the short name of the `include; its form is implementation dependent.
// `__LINE__ expands to the current line number. An `include switches both to
// the included file, and at its end they return to the including file, with
// `__LINE__ one more than the line of the `include. loc_inner.svh is found
// through the include directory include_loc_ch22 (:incdirs:, 22.4) and uses
// both macros on its lines 2 and 3. Since the form of the path is not fixed,
// the test prints whether the inner path ends with loc_inner.svh and contains
// include_loc_ch22, and whether the outer path ends with the name of this
// file and is the same before and after the `include.

module test_file_line_across_include;
  string before_file = `__FILE__;
  int before_line = `__LINE__;
`include "loc_inner.svh"
  int after_line = `__LINE__;
  string after_file = `__FILE__;

  function automatic bit ends_with(string s, string tail);
    return s.len() >= tail.len() && s.substr(s.len() - tail.len(), s.len() - 1) == tail;
  endfunction

  function automatic bit contains(string s, string part);
    for (int i = 0; i + part.len() <= s.len(); i++)
      if (s.substr(i, i + part.len() - 1) == part) return 1;
    return 0;
  endfunction

  initial begin
    $display("inner: line=%0d ends with loc_inner.svh=%0d contains include_loc_ch22=%0d",
             inner_line, ends_with(inner_file, "loc_inner.svh"),
             contains(inner_file, "include_loc_ch22"));
    $display("outer: before line=%0d after line=%0d", before_line, after_line);
    $display("outer: ends with own name=%0d same after include=%0d",
             ends_with(before_file, "test_file_line_across_include.sv"), before_file == after_file);
  end
endmodule
