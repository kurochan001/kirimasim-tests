/*
:name: test_ch16_sim_clocking_single
:description: a property declared in a clocking block may not be multiclocked, while a property there with no clock of its own is clocked only by the clocking block (IEEE 1800-2023 Section 16.16)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property p_bad declared inside clocking block cb has two clocking events of its own and is therefore multiclocked
:expected_stderr_regex: (?i)\A(?=[\s\S]*(?:error[^\n]*test_ch16_sim_clocking_single\.sv:42:(?:\d+:)?[^\n]*(?:multiclock|explicit[ -]?clock)|test_ch16_sim_clocking_single\.sv:42:(?:\d+:)?[^\n]*error[^\n]*(?:multiclock|explicit[ -]?clock)))
*/
// IEEE 1800-2023 §16.16 rule b: within a clocking block, no explicit
// clocking event is allowed in any property or sequence declaration, and
// multiclocked sequences and properties are not allowed. cb has the
// clocking event posedge clk. p_ok is clock-free, so it is treated as though
// posedge clk had been written as its leading clocking event, and is legal.
// p_bad writes two clocking events of its own, posedge clk2 and posedge
// clk, so it is multiclocked and is not allowed in the clocking block.
// Neither simulator reports this rule: Icarus Verilog 13.0 cannot parse the
// property declarations and Verilator 5.052 reports that assertion items in
// clocking blocks are unsupported. The test is kept as the specification of
// the rule, with no simulator in :oracle:, and notes/ch16-sim.md records the
// measured behavior.

module test_ch16_sim_clocking_single;
  logic clk = 0;
  logic clk2 = 0;
  logic a = 0;
  logic b = 0;

  always #5 clk = ~clk;
  always #7 clk2 = ~clk2;

  clocking cb @(posedge clk);
    property p_ok;
      a ##1 b;
    endproperty

    property p_bad;
      @(posedge clk2) a ##1 @(posedge clk) b;
    endproperty
  endclocking

  a_ok: assert property (cb.p_ok);
  a_bad: assert property (cb.p_bad);

  initial begin
    a = 1;
    #30;
    $finish;
  end
endmodule
