/*
:name: test_ch16_sim_automatic_restriction
:description: a static concurrent assertion may not reference an automatic variable, while the same assertion over a static variable is legal and evaluated (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a_bad is a static concurrent assertion whose expression references blk.av, a variable with automatic lifetime
:expected_stderr_regex: test_ch16_sim_automatic_restriction\.sv:46:
*/
// IEEE 1800-2023 §16.6: expressions that appear in procedural concurrent
// assertions may reference automatic variables as 16.14.6.1 describes;
// otherwise expressions in concurrent assertions shall not reference
// automatic variables. §6.21: a variable declared automatic in a named block
// has the lifetime of the block and is initialized on each entry to it.
// a_ok is a static assertion over sv, the static variable of the block sblk,
// and is legal. a_bad is a static assertion over av, the automatic variable
// of the block blk; it is not a procedural concurrent assertion, so it may
// not reference av. Nothing else in the design is intended to be illegal.
// Neither simulator reports this rule: Icarus Verilog 13.0 does not support
// concurrent assertions at all and Verilator 5.052 accepts the design. The
// test is kept as the specification of the rule, with no simulator in
// :oracle:, and notes/ch16-sim.md records the measured behavior.

module test_ch16_sim_automatic_restriction;
  logic clk = 0;
  int evaluations = 0;

  always #5 clk = ~clk;

  initial begin : blk
    automatic int av = 1;
    #60;
  end

  initial begin : sblk
    static int sv = 1;
    #60;
  end

  a_ok: assert property (@(posedge clk) sblk.sv == 1) evaluations++;

  a_bad: assert property (@(posedge clk) blk.av == 1);   // illegal

  initial begin
    #40;
    $display("legal assertion evaluations=%0d", evaluations);
    $finish;
  end
endmodule
