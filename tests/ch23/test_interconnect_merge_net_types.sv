/*
:name: test_interconnect_merge_net_types
:description: Port connections of interconnect nets merge them, through interconnect ports as well, into one net that takes the net type of the typed net they connect, here tri0, tri1 and wand (IEEE 1800-2023 Section 23.3.3.7.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7.1 6.6.8 23.3.3.7 6.6.3 6.6.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_interconnect_merge_net_types.expected
*/
// IEEE 1800-2023 §23.3.3.7.1: every port connection that involves an
// interconnect net merges the two nets into one. Two interconnect nets merge
// into an interconnect net; an interconnect net and a net of another type
// merge into a net of that other type. An interconnect net has no type of
// its own (§6.6.8), so the readers below see it through a wire input port,
// and a wire never dominates the other types used here (Table 23-1), so the
// order of the merges does not matter.
//   a: connects an undriven tri0 port and a reader: the merged net is a
//      tri0, which is 0 without drivers (§6.6.5);
//   b: the same with a tri1, which is 1;
//   c: connects a wire port driven with 1 and an interconnect port of mid,
//      inside which it connects a wand port driven with 0: the two
//      interconnect nets merge, and the whole net is a wand, which gives 0
//      (§6.6.3);
//   d: connects an interconnect port of mid2, inside which it connects an
//      undriven tri0 port: the merged net is a tri0 again, so 0.
// A merged net that did not take the other type would be z for a, b and d
// and x for c (wire), and connections that did not merge across the
// interconnect ports of mid and mid2 would leave c without the 0 of the wand
// and d without the pull of the tri0. Icarus Verilog 13.0 and Verilator
// 5.052 do not support interconnect nets, so this expected output follows
// the standard alone.

module interconnect_merge_net_types_tri0(inout tri0 w);
endmodule

module interconnect_merge_net_types_tri1(inout tri1 w);
endmodule

module interconnect_merge_net_types_wand0(inout wand w);
  assign w = 1'b0;
endmodule

module interconnect_merge_net_types_wire1(inout wire w);
  assign w = 1'b1;
endmodule

module interconnect_merge_net_types_reader(input wire logic i);
endmodule

module interconnect_merge_net_types_mid(inout interconnect p);
  interconnect_merge_net_types_wand0 l(p);
endmodule

module interconnect_merge_net_types_mid2(inout interconnect p);
  interconnect_merge_net_types_tri0 l(p);
endmodule

module test_interconnect_merge_net_types;
  interconnect a, b, c, d;

  interconnect_merge_net_types_tri0 ua(a);
  interconnect_merge_net_types_reader ra(a);

  interconnect_merge_net_types_tri1 ub(b);
  interconnect_merge_net_types_reader rb(b);

  interconnect_merge_net_types_wire1 uc(c);
  interconnect_merge_net_types_mid mc(c);
  interconnect_merge_net_types_reader rc(c);

  interconnect_merge_net_types_mid2 md(d);
  interconnect_merge_net_types_reader rd(d);

  initial begin
    #1;
    $display("a (tri0 port, no driver): %b", ra.i);
    $display("b (tri1 port, no driver): %b", rb.i);
    $display("c (wire 1 here, wand 0 inside mid): %b", rc.i);
    $display("d (tri0 port inside mid2, no driver): %b", rd.i);
  end
endmodule
