/*
:name: test_assertion_control_levels_and_scopes
:description: $assertoff with a levels argument and a list of scopes and assertions turns off the assertions of whole subtrees, of one level, or single assertions (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 21.7.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_control_levels_and_scopes.expected
*/
// IEEE 1800-2023 §20.11: $assertoff(levels, list) applies to the scopes and
// assertions in the list. levels works as for $dumpvars (21.7.1.2): 0 means
// the scope and every instance below it, 1 means the scope alone. The list
// can mix scopes and assertions. So $assertoff(0, u1) stops both assertions
// of u1, $assertoff(1, u2) stops u2's own assertion but not the one in its
// child u2.l, and $assertoff(0, u3, u4.chk) stops u3 and the assertion chk of
// u4. Every assertion here fails at each edge; u5 is not named and fails 3
// times by 32, as does u2.l.

module leaf_check (input logic clk);
  int fails = 0;
  chk: assert property (@(posedge clk) 0) else fails++;
endmodule

module mid_check (input logic clk);
  int fails = 0;
  chk: assert property (@(posedge clk) 0) else fails++;
  leaf_check l (clk);
endmodule

module test_assertion_control_levels_and_scopes;
  logic clk = 0;
  always #5 clk = ~clk;

  mid_check u1 (clk);
  mid_check u2 (clk);
  leaf_check u3 (clk);
  leaf_check u4 (clk);
  leaf_check u5 (clk);

  initial begin
    $assertoff(0, u1);
    $assertoff(1, u2);
    $assertoff(0, u3, u4.chk);
    #32;
    $display("u1: %0d, u1.l: %0d, u2: %0d, u2.l: %0d, u3: %0d, u4: %0d, u5: %0d", u1.fails,
             u1.l.fails, u2.fails, u2.l.fails, u3.fails, u4.fails, u5.fails);
    $finish;
  end
endmodule
