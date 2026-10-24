/*
:name: test_illegal_statement_label_before_join_any
:description: a statement label cannot be placed before join_any, which is not a statement (IEEE 1800-2023 Section 9.3.5)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the label done_l is placed before the join_any of the fork block
:expected_stderr_regex: test_illegal_statement_label_before_join_any\.sv:27:
*/
// IEEE 1800-2023 §9.3.5: a label can be given before any procedural
// statement, also before fork, but not before end, join, join_any or
// join_none, which do not form a statement. The label on the fork and the one
// on the statement inside it are legal; done_l is placed before join_any.
// Icarus Verilog 13.0 gives syntax errors also on the legal labels par_l and
// set_l, so its error does not count.

module test_illegal_statement_label_before_join_any;
  int a;

  initial begin
    par_l: fork
      set_l: a = 1;
    done_l: join_any   // illegal: a label before join_any
    #1 $display("%0d", a);
  end
endmodule
