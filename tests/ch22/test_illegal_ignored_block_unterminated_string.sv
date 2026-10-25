/*
:name: test_illegal_ignored_block_unterminated_string
:description: Text that conditional compilation leaves out still has to follow the lexical rules, so a string literal that is not closed on its line is an error even in a skipped `ifdef block (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.6 5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a quoted string literal in the skipped block has no closing quote on its line, which breaks the lexical rules of Clause 5 that skipped text still follows
:expected_stderr_regex: test_illegal_ignored_block_unterminated_string\.sv:24:
*/
// IEEE 1800-2023 §22.6: a block of text that the compiler ignores shall still
// follow the lexical conventions of Clause 5. A quoted string literal has to
// end on the line where it starts unless the newline is escaped (5.9). The
// macro SKIP_THIS_BLOCK is not defined, so the block is ignored, but its
// string literal is not closed, which is an error all the same. Icarus Verilog
// 13.0 accepts the design, and the 5.052 release of Verilator reports the
// unterminated string on the line after it.

module test_illegal_ignored_block_unterminated_string;
`ifdef SKIP_THIS_BLOCK
  initial $display("this string is not closed);   // illegal: no closing quote
`endif
  initial $display("done");
endmodule
