/*
:name: test_interconnect_and_net_port_types
:description: An interconnect net declaration with an implicit data type, a zero delay and one or two identifiers with unpacked dimensions, interconnect ports that carry a driven value through two module levels, and net ports written with a built-in net type, with a data type alone and with a user nettype (IEEE 1800-2023 Sections 6.6.8 and 23.3.3.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.8 23.3.3.7 A.2.1.3 A.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_and_net_port_types.expected
*/
// IEEE 1800-2023 A.2.1.3: an interconnect declaration is interconnect, an
// implicit data type, an optional delay value, a net identifier with zero or
// more unpacked dimensions and optionally one further such identifier, and a
// semicolon. 6.6.8: an interconnect net or port is typeless and carries the
// connections of its ports; it may be used only for net port and terminal
// connections and may be written as a net lvalue with other interconnect
// nets. A.2.2.1: a net port type is an optional built-in net type and a data
// type or implicit type, a nettype name, or interconnect and an implicit data
// type.
//   - bus, b2 and arr are interconnect nets; b2 carries the delay value 0
//     and arr has an unpacked dimension, and the declaration of arr and b2
//     has two identifiers,
//   - ic_src connects the output of ic_drv, a net port (an output port with
//     a data type alone would be a variable, 23.2.2.3), to its interconnect
//     output port,
//     ic_sink connects its interconnect input port to the input of ic_leaf,
//     and the value 8'hD comes out of ic_leaf as 8'hE,
//   - nt_leaf has a port of the user nettype nib_net, a port of wire [3:0]
//     (a net type and an implicit data type) and a port of logic [3:0] (a
//     data type alone), and its output adds the two driven values.
// Printed: y = e for bus, b2 and arr[0], nn = 9, wn = 3 and nty = 0000000c,
// since %h shows the leading zeros of the 32-bit int (21.2.1.2).
//
// Icarus Verilog 13.0 and Verilator 5.052 do not support interconnect nets or
// nettype ports.

nettype logic [3:0] nib_net;

module ic_drv (output wire logic [3:0] y);
  assign y = 4'hD;
endmodule

module ic_leaf (input logic [3:0] d, output logic [3:0] y);
  assign y = d + 1;
endmodule

module ic_src (output interconnect [3:0] ic);
  ic_drv u_drv (.y(ic));
endmodule

module ic_sink (input interconnect [3:0] ic, output logic [3:0] y);
  ic_leaf u_leaf (.d(ic), .y(y));
endmodule

module nt_leaf (input nib_net n, input wire [3:0] w, output int y);
  assign y = n + w;
endmodule

module test_interconnect_and_net_port_types;
  interconnect [3:0] bus;
  interconnect [3:0] #0 b2;
  interconnect [3:0] arr [2];
  nib_net nn;
  wire [3:0] wn;
  logic [3:0] y, y2, ya;
  int nty;

  ic_src u_src (.ic(bus));
  ic_sink u_sink (.ic(bus), .y(y));

  ic_src u_src2 (.ic(b2));
  ic_sink u_sink2 (.ic(b2), .y(y2));

  ic_src u_src3 (.ic(arr[0]));
  ic_sink u_sink3 (.ic(arr[0]), .y(ya));

  assign nn = 4'h9;
  assign wn = 4'h3;

  nt_leaf u_nt (.n(nn), .w(wn), .y(nty));

  initial #1 $display("ic: y=%h y2=%h ya=%h nn=%h wn=%h nty=%h",
                      y, y2, ya, nn, wn, nty);
endmodule
