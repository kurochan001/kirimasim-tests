/*
:name: test_resetall_after_tri0_implicit_wire
:description: After a `resetall that follows `default_nettype tri0, implicit nets are wire nets again: one driven only by z reads z, and one driven by 0 and by 1 reads x (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_resetall_after_tri0_implicit_wire.expected
*/
// IEEE 1800-2023 §22.8: when the `resetall directive is specified, implicit
// nets are of type wire. The file first sets `default_nettype tri0, so the
// implicit net t_float of tri0_side, driven only by z, is a tri0 net and reads
// 0; this shows that the directive took effect. After the `resetall, the
// implicit nets of the test module are wires: w_float, driven only by z,
// reads z, where a tri0 net would still read 0, and w_clash, with strong
// drivers of 0 and of 1, reads x, where a wand or wor net would read 0 or 1.
// The implicit nets are created by continuous assignments to undeclared
// names (6.10). The values are printed at time 1, after the continuous
// assignments have settled. The 5.054 release of Verilator does not support
// `default_nettype tri0 and stops at that directive.

`default_nettype tri0

module tri0_side;
  assign t_float = 1'bz;
endmodule

`resetall

module test_resetall_after_tri0_implicit_wire;
  assign w_float = 1'bz;
  assign w_clash = 1'b0;
  assign w_clash = 1'b1;

  tri0_side side();

  initial begin
    #1;
    $display("before resetall, only a z driver: %b", side.t_float);
    $display("after resetall, only a z driver: %b, drivers of 0 and 1: %b", w_float, w_clash);
  end
endmodule
