/*
:name: test_extern_module
:description: An extern module declaration gives the parameters and ports of a module, which its definition takes over with .*, and instances connect to them as declared (IEEE 1800-2023 Section 23.5)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.5 23.3.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_module.expected
*/
// IEEE 1800-2023 §23.5: an extern module declaration states the parameter and
// port lists of a module without its body. A module definition whose port
// list is .* has exactly the parameters and ports of its extern declaration,
// so em_add has the parameter W and the ports a, b and s. The instance
// overrides W and connects the ports by name with .* (23.3.2.4).

extern module em_add #(parameter int W = 4)
                      (input logic [W-1:0] a, input logic [W-1:0] b, output logic [W:0] s);

module em_add (.*);
  assign s = a + b;
endmodule

module test_extern_module;
  logic [7:0] a = 8'd200, b = 8'd100;
  logic [8:0] s;

  em_add #(.W(8)) u (.*);

  initial #1 $display("s = %0d, width %0d", s, $bits(u.s));
endmodule
