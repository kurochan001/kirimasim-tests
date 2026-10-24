/*
:name: test_illegal_statement_label_and_fork_name
:description: a fork block cannot have both a statement label before fork and a block name after it (IEEE 1800-2023 Section 9.3.5)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.5 9.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fork block has the statement label lab_l before fork and the block name blk_b after it
:expected_stderr_regex: test_illegal_statement_label_and_fork_name\.sv:31:
*/
// IEEE 1800-2023 §9.3.5: a statement label before begin or fork is the same as
// a block name after the keyword; it shall be illegal to have both. One fork
// block has a label and another a block name, which is legal; the third fork
// block has both.
// Icarus Verilog 13.0 gives syntax errors also on the legal labeled fork block
// one_l, so its error does not count.

module test_illegal_statement_label_and_fork_name;
  int a, b;

  initial begin
    one_l: fork
      a = 1;
    join : one_l
    fork : two_b
      b = 2;
    join
    lab_l: fork : blk_b   // illegal: label and block name together
      a = a + b;
    join
    $display("%0d", a);
  end
endmodule
