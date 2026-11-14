/*
:name: test_illegal_part_select_real_bound
:description: a bound of a non-indexed part-select has to be an integer expression, not a real one (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first bound of the non-indexed part-select v[RB:0] is the real constant RB
:expected_stderr_regex: test_illegal_part_select_real_bound\.sv:30:
*/
// IEEE 1800-2023 §11.5.1: both bounds of a non-indexed part-select shall be
// constant integer expressions, and §6.12 lists a real index expression of a
// part-select of a vector among the uses of real values that are not
// allowed. RB is a real localparam, so v[RB:0] has a constant bound that is
// not an integer expression; v[IB:0], with the int localparam IB, is legal.
// The 5.054 release of Verilator rejects the line with a message about the
// width of the value 3.0, not about a real bound, so it is not listed.

module test_illegal_part_select_real_bound;
  localparam int IB = 3;
  localparam real RB = 3.0;
  logic [7:0] v = 8'h5a;
  logic [3:0] a, b;

  initial begin
    a = v[IB:0];
    b = v[RB:0];   // illegal: a real bound of a part-select
  end
endmodule
