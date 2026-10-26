/*
:name: test_a2_1_3_interconnect_declaration_identifiers
:description: An interconnect declaration with an implicit data type, a zero delay and two identifiers, the second with an unpacked dimension, declares two interconnect nets, each of which carries a value from a driver to a leaf through the ports (IEEE 1800-2023 Sections 6.6.8 and 23.3.3.7, A.2.1.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.8 23.3.3.7 A.2.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a2_1_3_interconnect_declaration_identifiers.expected
*/
// IEEE 1800-2023 A.2.1.3: an interconnect declaration is the keyword, an
// implicit data type, an optional delay value, an interconnect identifier with
// zero or more unpacked dimensions, and optionally one further such
// identifier, then a semicolon. §6.6.8: an interconnect net has no data type
// and carries the value of the port it is connected to.
//
// The declaration interconnect [3:0] #0 ia, ib [2]; gives the two nets ia and
// ib, where ib is an unpacked array of two elements. ia is driven with 4'h1 by
// ic_src and read by ic_sink, whose leaf adds 1, so ya is 2. ib[1] is driven
// with 4'h2 and read the same way, so yb is 3. Neither release supports
// interconnect nets (Icarus Verilog 13.0 stops at the declaration and the
// 5.052 release of Verilator reports it as unsupported), so the expected
// output follows the standard.

module ic_drv #(parameter logic [3:0] V = 0) (output logic [3:0] y);
  assign y = V;
endmodule

module ic_leaf (input logic [3:0] d, output logic [3:0] y);
  assign y = d + 1;
endmodule

module ic_src (output interconnect [3:0] ic);
  ic_drv #(.V(4'h1)) u_drv (.y(ic));
endmodule

module ic_src2 (output interconnect [3:0] ic);
  ic_drv #(.V(4'h2)) u_drv (.y(ic));
endmodule

module ic_sink (input interconnect [3:0] ic, output logic [3:0] y);
  ic_leaf u_leaf (.d(ic), .y(y));
endmodule

module test_a2_1_3_interconnect_declaration_identifiers;
  interconnect [3:0] #0 ia, ib [2];
  logic [3:0] ya, yb;

  ic_src u_src_a (.ic(ia));
  ic_sink u_sink_a (.ic(ia), .y(ya));
  ic_src2 u_src_b (.ic(ib[1]));
  ic_sink u_sink_b (.ic(ib[1]), .y(yb));

  initial #1 $display("a=%h b=%h", ya, yb);
endmodule
