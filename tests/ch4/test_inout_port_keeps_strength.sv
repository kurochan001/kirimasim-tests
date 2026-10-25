/*
:name: test_inout_port_keeps_strength
:description: An inout port connects the nets inside and outside the module in both directions without reducing any strength, while a tran between two nets reduces a supply strength to strong (IEEE 1800-2023 Section 4.9.6)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.6 28.13 21.2.1.4 23.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_inout_port_keeps_strength.expected
*/
// IEEE 1800-2023 §4.9.6: an inout port is a bidirectional connection between
// the local net and the outside net, like an always-enabled tran, but
// without any strength reduction; §28.13: a tran reduces a supply strength
// to strong. %v prints the strength and value of a scalar net (§21.2.1.4).
// The child drives its inout port a with supply strength and its inout
// port b with weak strength, and reads its inout port c, which the parent
// drives with pull strength. The parent sees Su1 on the net of a and We0 on
// the net of b, and the child sees Pu1 on c. A tran from the net of a to
// another net gives St1 there. On the net of d both sides drive: the
// parent a strong 0 and the child a pull 1, and both sides see St0.

module inout_strength_child(inout a, inout b, inout c, inout d);
  assign (supply1, supply0) a = 1'b1;
  assign (weak1, weak0) b = 1'b0;
  assign (pull1, pull0) d = 1'b1;
  initial #1 $display("child: c=%v d=%v", c, d);
endmodule

module test_inout_port_keeps_strength;
  wire pa, pb, pc, pd, ta;

  assign (pull1, pull0) pc = 1'b1;
  assign (strong1, strong0) pd = 1'b0;
  tran t1(pa, ta);

  inout_strength_child u(.a(pa), .b(pb), .c(pc), .d(pd));

  initial #2 $display("parent: a=%v b=%v d=%v tran=%v", pa, pb, pd, ta);
endmodule
