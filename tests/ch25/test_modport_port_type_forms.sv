/*
:name: test_modport_port_type_forms
:description: a port declared as interface_name.modport names the instance through that modport, and interface.modport accepts any interface that has a modport of that name (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_port_type_forms.expected
*/
// IEEE 1800-2023 §25.5: a port written interface_name.modport_name p makes
// p a local name for a hierarchical reference to the connected instance,
// seen through that modport. Written interface.modport_name p, it accepts an
// instance of any interface that has a modport of that name, and then
// uses that modport.
// Interfaces pf_a and pf_b both have a modport view with the variable x,
// set to 1 in pf_a and to 7 in pf_b. Module pf_named takes pf_a.view;
// module pf_generic takes interface.view and is instantiated once with an
// instance of pf_a and once with one of pf_b. Each prints p.x at the time
// given by its parameter T.

interface pf_a;
  logic [3:0] x = 4'h1;
  logic [3:0] y = 4'h2;
  modport view (input x);
endinterface

interface pf_b;
  logic [3:0] x = 4'h7;
  modport view (input x);
endinterface

module pf_named (pf_a.view p);
  initial #1 $display("pf_a.view port: p.x=%h", p.x);
endmodule

module pf_generic #(parameter int T = 2, parameter string WHO = "") (interface.view p);
  initial #(T) $display("interface.view port on %s: p.x=%h", WHO, p.x);
endmodule

module test_modport_port_type_forms;
  pf_a ia ();
  pf_b ib ();
  pf_named n (.p(ia));
  pf_generic #(.T(2), .WHO("pf_a")) ga (.p(ia));
  pf_generic #(.T(3), .WHO("pf_b")) gb (.p(ib));
endmodule
