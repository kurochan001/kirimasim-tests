/*
:name: test_generic_interface_port
:description: A module port declared with the keyword interface accepts instances of different interfaces (IEEE 1800-2023 Section 25.3.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3.3 25.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generic_interface_port.expected
*/
// IEEE 1800-2023 §25.3.3: a port declared as interface, without the name of a
// particular interface, is a generic interface reference; the interface it
// refers to is the one each instance connects to it. So one module can read the
// signal v of two different interfaces that both declare it.

interface gip_a;
  logic [7:0] v = 8'h0a;
endinterface

interface gip_b;
  logic [7:0] v = 8'h0b;
  logic [7:0] extra = 8'hff;
endinterface

module gip_reader(interface bus, output logic [7:0] seen);
  assign seen = bus.v;
endmodule

module test_generic_interface_port;
  gip_a ia();
  gip_b ib();
  logic [7:0] s1, s2;

  gip_reader r1(.bus(ia), .seen(s1));
  gip_reader r2(.bus(ib), .seen(s2));

  initial #1 $display("through gip_a: %h, through gip_b: %h", s1, s2);
endmodule
