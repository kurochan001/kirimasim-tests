/*
:name: test_interface_specify_terminal
:description: A signal of an interface port can be a terminal of a module path in a specify block, with the direction its modport gives it (IEEE 1800-2023 Section 25.6)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.6 30.3 30.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_specify_terminal.expected
*/
// IEEE 1800-2023 §25.6: when a port of a module is an interface, each of its
// signals can be a terminal in the specify block, with the direction given by
// the interface or restricted by the modport. The modport in makes p.i an
// input, and the module path from p.i to o (30.4) has a delay of 3, so the
// rise of p.i at 10 reaches o at 13.

`timescale 1ns/1ns

interface test_interface_specify_terminal_if;
  logic i;
  modport in (input i);
endinterface

module test_interface_specify_terminal_cell (test_interface_specify_terminal_if.in p,
                                              output wire o);
  assign o = p.i;
  specify
    (p.i => o) = 3;
  endspecify
endmodule

module test_interface_specify_terminal;
  test_interface_specify_terminal_if pi();
  wire o;

  test_interface_specify_terminal_cell c(pi, o);

  initial begin
    pi.i = 0;
    #10 pi.i = 1;
    #2 $display("t=%0t: o=%b", $time, o);
    #2 $display("t=%0t: o=%b", $time, o);
  end
endmodule
