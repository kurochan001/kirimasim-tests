/*
:name: test_illegal_clocking_block_explicit_clock
:description: A sequence declaration inside a clocking block shall not have an explicit clocking event, because it is treated as prefixed by the clocking event of the block (IEEE 1800-2023 Section 16.16)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sequence s_bad inside clocking cb has its own explicit @(posedge clk)
:expected_stderr_regex: test_illegal_clocking_block_explicit_clock\.sv:32:
*/
// IEEE 1800-2023 §16.16: within a clocking block, no explicit clocking event
// is allowed in any property or sequence declaration; each is treated as
// though the clocking event of the block had been written as its leading
// event. p_ok writes no event and is legal. s_bad writes @(posedge clk)
// explicitly, which repeats the event of cb, and is illegal even though the
// event is the same.

module test_illegal_clocking_block_explicit_clock;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  clocking cb @(posedge clk);
    property p_ok;
      a ##1 b;
    endproperty

    sequence s_bad;
      @(posedge clk) a;   // illegal: explicit clock in a clocking block
    endsequence
  endclocking
endmodule
