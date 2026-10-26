/*
:name: test_illegal_cg_default_sequence_array_new
:description: a default sequence bin shall not use the [] bin-array notation (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default sequence bin allother is declared with []
:expected_stderr_regex: test_illegal_cg_default_sequence_array_new\.sv:27:
*/
// IEEE 1800-2023 §19.5.2: a default sequence specification shall not accept
// multiple transition bins; the [] notation is not allowed. The transition
// bin t is an ordinary bounded transition, and the default sequence bin other
// without brackets is legal. The default sequence allother[] uses the []
// notation and is the one error.

module test_illegal_cg_default_sequence_array_new;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins t = (1 => 2);
      bins other = default sequence;
      bins allother[] = default sequence;   // illegal: [] on default sequence
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule
