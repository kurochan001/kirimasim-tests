/*
:name: test_generic_interface_port
:description: A port of the generic interface type can be connected to instances of different interfaces, while a port of a named interface type takes that interface (IEEE 1800-2023 Section 23.3.3.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generic_interface_port.expected
*/
// IEEE 1800-2023 §23.3.3.4: an interface port is always connected to an
// interface instance or a higher interface port. A port of the generic type
// interface (25.3.3) can be connected to an instance of any interface; a port
// of a named interface type (25.3.2) only to an instance of that interface.
// show takes a generic interface and is connected to instances of two
// different interfaces, which both have a member named tag.

interface test_generic_interface_port_a;
  string tag = "first";
endinterface

interface test_generic_interface_port_b;
  string tag = "second";
  int extra = 3;
endinterface

module test_generic_interface_port_show #(int AT = 1) (interface bus);
  initial #AT $display("%m: %s", bus.tag);
endmodule

module test_generic_interface_port_named(test_generic_interface_port_b bus);
  initial #3 $display("%m: %s %0d", bus.tag, bus.extra);
endmodule

module test_generic_interface_port;
  test_generic_interface_port_a ia();
  test_generic_interface_port_b ib();

  test_generic_interface_port_show #(1) s1(ia);
  test_generic_interface_port_show #(2) s2(ib);
  test_generic_interface_port_named n(ib);
endmodule
