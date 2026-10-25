/*
:name: test_port_default_value_module_scope
:description: The default value of an input port is a constant expression evaluated in the scope of the module that declares the port, with that instance's parameter values, not in the scope of the instantiating module, where names of the same spelling have other values (IEEE 1800-2023 Section 23.2.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.4 23.3.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_default_value_module_scope.expected
*/
// IEEE 1800-2023 §23.2.2.4: a singular input port can have a default value,
// a constant expression that is evaluated in the scope of the module where it
// is declared, not in the scope of the instantiating module. The port a
// defaults to the compilation-unit constant DFLT_BASE (8'h11) and the port b
// to 2 * K, K being a parameter of the module (3 unless overridden). The top
// module declares its own DFLT_BASE (8'h22) and K (100), which the defaults
// do not see:
//   u0 omits a and b (named connections, §23.3.2.2): a = 11, b = 6;
//   u1 overrides K with 5 and omits a and b: a = 11, b = 2 * 5 = 10 (0a);
//   u2 connects DFLT_BASE and K of the top module explicitly: a = 22 and
//      b = 100 (64), the values of the instantiating scope.
// Evaluating the defaults in the top module would give a = 22 and b = 200
// (c8) for u0 and u1.

localparam logic [7:0] DFLT_BASE = 8'h11;

module port_default_value_module_scope_m #(parameter int K = 3)
  (input logic [7:0] a = DFLT_BASE, input logic [7:0] b = 2 * K,
   output logic [7:0] ya, output logic [7:0] yb);
  assign ya = a;
  assign yb = b;
endmodule

module test_port_default_value_module_scope;
  localparam logic [7:0] DFLT_BASE = 8'h22;
  localparam int K = 100;
  logic [7:0] ya0, yb0, ya1, yb1, ya2, yb2;

  port_default_value_module_scope_m u0(.ya(ya0), .yb(yb0));
  port_default_value_module_scope_m #(.K(5)) u1(.ya(ya1), .yb(yb1));
  port_default_value_module_scope_m u2(.a(DFLT_BASE), .b(K), .ya(ya2), .yb(yb2));

  initial #1 $display("u0: a=%h b=%h  u1: a=%h b=%h  u2: a=%h b=%h",
                      ya0, yb0, ya1, yb1, ya2, yb2);
endmodule
