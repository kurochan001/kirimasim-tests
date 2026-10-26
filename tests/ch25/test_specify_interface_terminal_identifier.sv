/*
:name: test_specify_interface_terminal_identifier
:description: A signal of an interface port can be the input identifier of a module path, written interface_identifier.port_identifier, and an output port is its output identifier; the path delays the output by its path delay (IEEE 1800-2023 Sections 25.6 and 30.4.2, and A.7.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.6 30.4.2 A.7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_interface_terminal_identifier.expected
*/
// IEEE 1800-2023 A.7.3: an input_identifier is an input port, an inout port
// or an interface_identifier followed by a dot and a port_identifier, and an
// output_identifier is an output port, an inout port or the same interface
// form. §25.6: a signal of an interface port can be a terminal of a module
// path, with the direction that its modport gives it. §30.4.2: the module
// path (p.s => o) with delay 3 delays a change of the interface signal p.s by
// 3 before it reaches the output o.
//
// The interface signal p.s rises at 10 and falls at 34, so o stays 0 at 12,
// becomes 1 at 13 and stays 1 at 14, and falls at 37, so it is still 1 at 36
// and 0 at 38. Icarus Verilog 13.0 does not accept an interface port in a
// module, and the 5.052 release of Verilator ignores module path delays.

`timescale 1ns/1ns

interface test_specify_interface_terminal_identifier_if;
  logic s;
  modport inp (input s);
endinterface

module test_specify_interface_terminal_identifier_cell
  (test_specify_interface_terminal_identifier_if.inp p, output wire o);
  assign o = p.s;
  specify
    (p.s => o) = 3;
  endspecify
endmodule

module test_specify_interface_terminal_identifier;
  test_specify_interface_terminal_identifier_if pi ();
  wire o;

  test_specify_interface_terminal_identifier_cell u (pi, o);

  initial begin
    pi.s = 1'b0;
    #10 pi.s = 1'b1;
    #2  $display("t=%0t o=%b", $time, o);
    #2  $display("t=%0t o=%b", $time, o);
    #20 pi.s = 1'b0;
    #2  $display("t=%0t o=%b", $time, o);
    #2  $display("t=%0t o=%b", $time, o);
  end
endmodule
