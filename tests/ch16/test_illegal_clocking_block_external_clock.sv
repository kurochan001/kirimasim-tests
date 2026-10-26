/*
:name: test_illegal_clocking_block_external_clock
:description: a sequence or property declared outside a clocking block and instantiated inside it has a different clock
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_inner inside cb instantiates p_ext, which is clocked by clk2 while cb is clocked by clk1
:expected_stderr_regex: test_illegal_clocking_block_external_clock\.sv:28:
*/
// IEEE 1800-2023 §16.16: a sequence or property declared outside a clocking
// block and instantiated inside it shall be singly clocked with a clock
// identical to that of the block. p_ext is clocked by clk2, while cb is
// clocked by clk1, so the instance p_ext in p_inner is illegal.

module test_illegal_clocking_block_external_clock;
  logic clk1 = 0, clk2 = 0, a = 0;

  property p_ext;
    @(posedge clk2) a;
  endproperty

  clocking cb @(posedge clk1);
    property p_inner;
      p_ext;   // illegal
    endproperty
  endclocking
endmodule
