/*
:name: test_port_net_and_variable_connections
:description: A net input takes any compatible expression and is all z when unconnected, a net output drives a net, a variable or a concatenation of nets or of variables, and a variable output drives a net or a concatenation of nets, and such a net may have other drivers (IEEE 1800-2023 Section 23.3.3.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.3 23.3.3.2 6.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_net_and_variable_connections.expected
*/
// IEEE 1800-2023 §23.3.3.3: an input port of a net type can be connected to
// any expression of a compatible data type and is 'z when left
// unconnected; an output port of a net type can be connected to a net or a
// variable, or to a concatenation of nets or of variables. §23.3.3.2: an
// output port of a variable type can be connected to a net or a
// concatenation of nets, and such a net may have several drivers.
// The module passes its net input ni to its net output no and drives its
// variable output vo with 4'b0101:
//   m1: ni = a & b (4'b1000) gives the net w 1000; vo drives the net wm,
//       which a continuous assignment also drives with 4'b0011, so the wire
//       resolves (§6.6.1) to 0xx1;
//   m2: ni unconnected gives zzzz to the variable v; vo drives {w1, w2}:
//       01 and 01;
//   m3: ni = 4'h6 drives the concatenation of nets {w3, w4}: 01 and 10;
//       vo drives the net wv: 0101;
//   m4: ni = 4'h9 drives the concatenation of variables {v1, v2}: 10 and
//       01.

module port_net_variable_m(input wire [3:0] ni, output wire [3:0] no, output logic [3:0] vo);
  assign no = ni;
  initial vo = 4'b0101;
endmodule

module test_port_net_and_variable_connections;
  logic [3:0] a = 4'b1100, b = 4'b1010;
  wire [3:0] w, wm, wv, w5;
  wire [1:0] w1, w2, w3, w4;
  logic [3:0] v;
  logic [1:0] v1, v2;

  assign wm = 4'b0011;

  port_net_variable_m m1(.ni(a & b), .no(w), .vo(wm));
  port_net_variable_m m2(.ni(), .no(v), .vo({w1, w2}));
  port_net_variable_m m3(.ni(4'h6), .no({w3, w4}), .vo(wv));
  port_net_variable_m m4(.ni(4'h9), .no({v1, v2}), .vo(w5));

  initial begin
    #1;
    $display("m1: w=%b wm=%b", w, wm);
    $display("m2: v=%b w1=%b w2=%b", v, w1, w2);
    $display("m3: w3=%b w4=%b wv=%b", w3, w4, wv);
    $display("m4: v1=%b v2=%b", v1, v2);
  end
endmodule
