/*
:name: test_empty_named_connection_ignores_default
:description: An input port with a default value takes the default when its connection is omitted, but is left unconnected by an empty named connection .q() (IEEE 1800-2023 Section 23.3.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.2 23.3.2.1 23.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_empty_named_connection_ignores_default.expected
*/
// IEEE 1800-2023 §23.2.2.4: an input port can have a default value, which the
// port takes when the instance omits its connection: with named connections
// by leaving the port out (23.3.2.2), with ordered connections by an empty
// position (23.3.2.1). §23.3.2.2: an explicit empty named connection, .q(),
// leaves the port unconnected instead and the default is not used. The
// input port q is a net, so unconnected it is z.

module port_with_default (input logic [3:0] q = 4'h7, output logic [3:0] y);
  assign y = q;
endmodule

module test_empty_named_connection_ignores_default;
  logic [3:0] y1, y2, y3, y4;
  port_with_default omitted (.y(y1));
  port_with_default empty (.q(), .y(y2));
  port_with_default given (.q(4'h3), .y(y3));
  port_with_default ordered (, y4);

  initial #1 $display("omitted: %b, .q(): %b, .q(4'h3): %b, ordered and empty: %b", y1, y2,
                      y3, y4);
endmodule
