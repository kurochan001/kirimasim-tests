/*
:name: test_illegal_part_select_real_second_bound
:description: the second bound of a non-indexed part-select has to be an integer expression, not a real one (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second bound of the non-indexed part-select v[7:RL] is the real constant RL
:expected_stderr_regex: test_illegal_part_select_real_second_bound\.sv:33:
*/
// IEEE 1800-2023 §11.5.1: both bounds of a non-indexed part-select shall be
// constant integer expressions, and §6.12 lists a real index expression of a
// part-select of a vector among the uses of real values that are not
// allowed. RL is a real localparam, so v[7:RL] has a constant second bound
// that is not an integer expression; v[7:IL], with the int localparam IL, is
// legal. The first bound is the integer constant 7 in both selects; another
// test puts the real constant in the first bound.
// The 5.054 release of Verilator rejects the line with messages about the
// width of the value 4.0 and of the range, not about a real bound, so it is
// not listed.

module test_illegal_part_select_real_second_bound;
  localparam int IL = 4;
  localparam real RL = 4.0;
  logic [7:0] v = 8'h5a;
  logic [3:0] a, b;

  initial begin
    a = v[7:IL];
    b = v[7:RL];   // illegal: a real second bound of a part-select
  end
endmodule
