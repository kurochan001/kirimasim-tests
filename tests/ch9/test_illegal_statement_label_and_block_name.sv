/*
:name: test_illegal_statement_label_and_block_name
:description: a begin block cannot have both a statement label before it and a block name after begin (IEEE 1800-2023 Section 9.3.5)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.5 9.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the block has the statement label lab_l before begin and the block name blk_b after it
:expected_stderr_regex: test_illegal_statement_label_and_block_name\.sv:31:
*/
// IEEE 1800-2023 §9.3.5: a statement label before begin or fork is the same as
// a block name after the keyword; it shall be illegal to have both. One block
// has a label and the other a block name, which is legal; the third block has
// both.
// Icarus Verilog 13.0 gives syntax errors also on the legal labeled block
// one_l, so its error does not count.

module test_illegal_statement_label_and_block_name;
  int a;

  initial begin
    one_l: begin
      a = 1;
    end : one_l
    begin : two_b
      a = a + 1;
    end
    lab_l: begin : blk_b   // illegal: label and block name together
      a = a + 2;
    end
    $display("%0d", a);
  end
endmodule
