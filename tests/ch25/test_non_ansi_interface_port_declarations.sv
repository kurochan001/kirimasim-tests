/*
:name: test_non_ansi_interface_port_declarations
:description: non-ANSI interface port declarations with and without a modport, each declaring a list of ports, one of them an unpacked array of interface ports, through which the module writes the connected interface instances (IEEE 1800-2023 Sections 25.3, A.2.1.2, A.2.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5 23.2.2.1 23.3.3.4 23.3.3.5 A.2.1.2 A.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_non_ansi_interface_port_declarations.expected
*/
// IEEE 1800-2023 A.2.1.2 and §23.2.2.1: a non-ANSI port can be declared as an
// interface port, by an interface name followed by a list of port names, or
// by an interface name, a dot and a modport name followed by such a list.
// A.2.3: the list has one or more comma-separated names, each with optional
// unpacked dimensions. §25.3, §25.5, §23.3.3.4, §23.3.3.5: an interface port
// refers to the interface instance it is connected to, restricted to the
// modport when one is named, and an unpacked array of interface ports is
// connected to an array of instances element by element.
// ip_child declares a and k as ip_bus ports and b and c[2] as ip_bus.src
// ports; it adds to the count of a and k and writes the data of b, c[0] and
// c[1]. The top prints the instances it connected, which show the writes.
// Neither release takes the test: Icarus Verilog 13.0 has no non-ANSI
// interface port declarations, and the other release does not declare the
// names after the first in a list that follows a modport name, nor accept an
// array of interface ports declared this way.

interface ip_bus;
  logic [7:0] data = 8'h00;
  int count = 10;
  modport src(output data);
endinterface

module ip_child(a, k, b, c);
  ip_bus a, k;
  ip_bus.src b, c [2];

  initial begin
    #1;
    a.count = a.count + 5;
    k.count = k.count * 2;
    b.data = 8'h21;
    c[0].data = 8'h30;
    c[1].data = 8'h31;
  end
endmodule

module test_non_ansi_interface_port_declarations;
  ip_bus i_a(), i_k(), i_b();
  ip_bus i_c [2] ();

  ip_child u (i_a, i_k, i_b, i_c);

  initial begin
    #2;
    $display("a.count=%0d k.count=%0d b.data=%h", i_a.count, i_k.count, i_b.data);
    $display("c[0].data=%h c[1].data=%h", i_c[0].data, i_c[1].data);
  end
endmodule
