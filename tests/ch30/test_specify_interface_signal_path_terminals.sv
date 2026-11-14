/*
:name: test_specify_interface_signal_path_terminals
:description: A signal of an interface port, written interface_identifier.port_identifier, can be the source of a simple module path when its modport makes it an input and the destination when it makes it an output, and the path delays the destination (IEEE 1800-2023 Section 30.4.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.2 25.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_interface_signal_path_terminals.expected
*/
// IEEE 1800-2023 §30.4.2, Syntax 30-3: the input and the output identifier
// of a simple path can each be a port, an inout port or an interface
// identifier with a port identifier. §25.6: each signal of an interface port
// becomes a terminal, with the direction its modport gives it.
//
// The cell has the interface port p, whose modport makes a and b inputs and
// y and z outputs, the input port i and the output port o:
//   (p.a => p.y) = 30     interface signal to interface signal, p.y = p.a
//   (p.b => o) = 40       interface signal to output port,      o = p.b
//   (i => p.z) = 50       input port to interface signal,       p.z = i
// p.a rises at 100 (p.y at 130), p.b at 200 (o at 240) and i at 300 (p.z at
// 350); then p.a falls at 400 (p.y at 430).
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs.
//
// Icarus Verilog 13.0 does not accept an interface port in a module, and
// the 5.054 release of Verilator ignores module path delays.

`timescale 1ns/1ns

interface test_specify_interface_signal_path_terminals_if;
  logic a = 1'b0, b = 1'b0;
  logic y, z;
  modport mp (input a, input b, output y, output z);
endinterface

module test_specify_interface_signal_path_terminals_cell
  (test_specify_interface_signal_path_terminals_if.mp p, input i, output o);
  assign p.y = p.a;
  assign o = p.b;
  assign p.z = i;
  specify
    (p.a => p.y) = 30;
    (p.b => o) = 40;
    (i => p.z) = 50;
  endspecify
endmodule

module test_specify_interface_signal_path_terminals;
  test_specify_interface_signal_path_terminals_if pi ();
  reg i = 1'b0;
  wire o;
  logic [2:0] prev;

  test_specify_interface_signal_path_terminals_cell u (pi, i, o);

  initial begin
    #100 pi.a = 1'b1;
    #100 pi.b = 1'b1;
    #100 i = 1'b1;
    #100 pi.a = 1'b0;
  end

  initial begin
    #95 prev = {pi.y, o, pi.z};
    repeat (40) begin
      #10 if ({pi.y, o, pi.z} != prev)
        $display("%0d: p.y=%b o=%b p.z=%b", $time - 5, pi.y, o, pi.z);
      prev = {pi.y, o, pi.z};
    end
    $finish;
  end
endmodule
