/*
:name: test_interconnect_declaration_generic_forms
:description: Interconnect declarations in the generic form, with no range, with signing and a packed range and one delay value, and with two identifiers that each have their own unpacked dimension, declare nets that connect driver and receiver ports, whole arrays and single elements (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_declaration_generic_forms.expected
*/
// IEEE 1800-2023 §6.7 (Syntax 6-2): an interconnect declaration is the
// keyword interconnect, an implicit data type (optional signing and packed
// dimensions, no data type), at most one delay value, and one net identifier,
// or two separated by a comma, each with its own unpacked dimensions. Such a
// net has no data type and serves only in port connections; connected to net
// ports, it merges with them into a net of their type (23.3.3.7.1).
// The test declares:
//   s, with no range and no signing, between 1-bit ports;
//   sv, with signing, the range [3:0] and the single delay value 2, between
//   signed 4-bit ports;
//   ia [0:1] and ib [1:0] in one declaration with the range [3:0], each with
//   its own unpacked dimension: ia connects array ports as a whole, and the
//   two elements of ib come from two drivers and go to one array port.
// The drivers drive constants from time 0, and the values that reach the
// receiver ports are printed at time 10, after any delay of the nets.
// Oracle checks: interconnect nets are supported neither by Icarus Verilog
// 13.0 nor by the 5.054 release of Verilator, so the expected output follows
// the cited clause alone; with wire nets in place of the interconnect nets,
// the 5.054 release prints the expected line.

module test_interconnect_declaration_generic_forms_drv
  #(parameter logic [3:0] V = 0) (output wire logic [3:0] y);
  assign y = V;
endmodule

module test_interconnect_declaration_generic_forms_drv1 (output wire logic y);
  assign y = 1'b1;
endmodule

module test_interconnect_declaration_generic_forms_drvs (output wire logic signed [3:0] y);
  assign y = -4'sd3;
endmodule

module test_interconnect_declaration_generic_forms_drv2 (output wire logic [3:0] y [0:1]);
  assign y[0] = 4'h1;
  assign y[1] = 4'h2;
endmodule

module test_interconnect_declaration_generic_forms_rcv1 (input wire logic d);
endmodule

module test_interconnect_declaration_generic_forms_rcvs (input wire logic signed [3:0] d);
endmodule

module test_interconnect_declaration_generic_forms_rcv2 (input wire logic [3:0] d [0:1]);
endmodule

module test_interconnect_declaration_generic_forms_rcv2r (input wire logic [3:0] d [1:0]);
endmodule

module test_interconnect_declaration_generic_forms;
  interconnect s;
  interconnect signed [3:0] #2 sv;
  interconnect [3:0] ia [0:1], ib [1:0];

  test_interconnect_declaration_generic_forms_drv1 d1(s);
  test_interconnect_declaration_generic_forms_rcv1 r1(s);
  test_interconnect_declaration_generic_forms_drvs d2(sv);
  test_interconnect_declaration_generic_forms_rcvs r2(sv);
  test_interconnect_declaration_generic_forms_drv2 d3(ia);
  test_interconnect_declaration_generic_forms_rcv2 r3(ia);
  test_interconnect_declaration_generic_forms_drv #(4'h5) d4(ib[1]);
  test_interconnect_declaration_generic_forms_drv #(4'h6) d5(ib[0]);
  test_interconnect_declaration_generic_forms_rcv2r r4(ib);

  initial
    #10 $display("s=%b sv=%0d ia=%h %h ib[1]=%h ib[0]=%h", r1.d, r2.d, r3.d[0], r3.d[1],
                 r4.d[1], r4.d[0]);
endmodule
