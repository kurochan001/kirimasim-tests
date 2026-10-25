/*
:name: test_syntax_net_alias_three_lvalues
:description: one alias statement joins three nets into one, so the driver of the last is seen on the other two, and the driver of the first in a second statement on the others (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11 A.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_net_alias_three_lvalues.expected
*/
// IEEE 1800-2023 §10.11, A.6.1: an alias statement is alias, two or more
// net lvalues separated by =, and a semicolon; all of them name the same
// bits of one net. Here one statement joins a, b and c, of which only c is
// driven, and another joins p, q and r, of which only p is driven. All three
// names of each net show the value of its driver as it changes, while the
// net d, which is not aliased, keeps the value of its own driver.

module test_syntax_net_alias_three_lvalues;
  wire [3:0] a, b, c, p, q, r, d;
  logic [3:0] dc, dp;

  alias a = b = c;
  alias p = q = r;

  assign c = dc;
  assign p = dp;
  assign d = 4'h3;

  initial begin
    dc = 4'h9; dp = 4'h5;
    #1 $display("a=%h b=%h c=%h p=%h q=%h r=%h d=%h", a, b, c, p, q, r, d);
    dc = 4'h6; dp = 4'ha;
    #1 $display("a=%h b=%h c=%h p=%h q=%h r=%h d=%h", a, b, c, p, q, r, d);
  end
endmodule
