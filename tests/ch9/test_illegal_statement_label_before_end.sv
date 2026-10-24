/*
:name: test_illegal_statement_label_before_end
:description: a statement label cannot be placed before end, which is not a statement (IEEE 1800-2023 Section 9.3.5)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the label done_l is placed before the end of the begin-end block
:expected_stderr_regex: test_illegal_statement_label_before_end\.sv:28:
*/
// IEEE 1800-2023 §9.3.5: a label can be given before any procedural
// statement, also before begin, but not before end, join, join_any or
// join_none, which do not form a statement. The labels on the assignment and
// on the begin are legal; done_l is placed before end.
// Icarus Verilog 13.0 gives a syntax error also on the legal label first_l, so
// its error does not count.

module test_illegal_statement_label_before_end;
  int a;

  initial begin
    first_l: a = 1;
    blk_l: begin
      a = a + 1;
    done_l: end   // illegal: a label before end
    $display("%0d", a);
  end
endmodule
