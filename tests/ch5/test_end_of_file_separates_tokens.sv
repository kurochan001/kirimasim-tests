/*
:name: test_end_of_file_separates_tokens
:description: The end of a source file is white space, so a file that ends right after a token without a newline is complete and its last token does not run into the first token of the next file (IEEE 1800-2023 Section 5.3)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: eof_separator_part_a.sv eof_separator_part_b.sv
:expected_stdout: @test_end_of_file_separates_tokens.expected
*/
// IEEE 1800-2023 §5.3: white space is spaces, tabs, newlines, formfeeds and
// the end of file, and it separates tokens.
// The two files that :files: names, and this file, end right after the
// keyword endmodule, with no newline. The second file starts with the
// keyword module, so endmodule and module are only separated by the end of
// the first file. The test instantiates the modules of both files and prints
// their values.

module test_end_of_file_separates_tokens;
  eof_separator_part_a a ();
  eof_separator_part_b b ();

  initial #1 $display("a=%0d b=%0d", a.val, b.val);
endmodule