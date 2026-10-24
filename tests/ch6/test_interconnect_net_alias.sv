/*
:name: test_interconnect_net_alias
:description: An alias statement can join interconnect nets, so a driver connected to one of them reaches a reader connected to the other (IEEE 1800-2023 Section 6.6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.8 10.11 23.3.3.7.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_interconnect_net_alias.expected
*/
// IEEE 1800-2023 §6.6.8: an alias statement may have interconnect nets as its
// net_lvalues; alias makes its operands names of the same net (10.11), whose
// type then comes from its port connections (23.3.3.7.1).
// The interconnect nets src and dst are aliased. A driver's output wire port
// drives 1 onto src, and a reader's input wire port is connected to dst only;
// the reader sees 1. Without the alias, dst would have no driver and be z.
// A second pair, lone_src and lone_dst, is connected the same way without an
// alias, as the control.
// Oracle checks: neither Icarus Verilog 13.0 nor the 5.052 release supports
// interconnect nets, so the expected output follows the cited clauses alone.

module test_interconnect_net_alias_drv(output wire o);
  assign o = 1'b1;
endmodule

module test_interconnect_net_alias_reader(input wire logic i);
endmodule

module test_interconnect_net_alias;
  interconnect src, dst, lone_src, lone_dst;

  alias src = dst;

  test_interconnect_net_alias_drv d(src);
  test_interconnect_net_alias_reader r(dst);
  test_interconnect_net_alias_drv ld(lone_src);
  test_interconnect_net_alias_reader lr(lone_dst);

  initial #1 $display("aliased: %b, not aliased: %b", r.i, lr.i);
endmodule
