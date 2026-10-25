/*
:name: test_syntax_interface_instantiation_forms
:description: interface instantiations without parameter values, with ordered values for two instances in one statement, with a named value and wildcard ports, and with an empty parameter list for an array of instances (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 23.3.2 23.10.2 A.4.1.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_interface_instantiation_forms.expected
*/
// IEEE 1800-2023 A.4.1.2: an interface instantiation is the interface name,
// an optional parameter value assignment, one or more instances separated by
// commas, and a semicolon. §25.3: an interface is instantiated like a module,
// and its ports are connected and its parameters overridden in the same ways
// (23.3.2, 23.10.2).
//
// bus_if keeps the low W bits of its port seed in data and W * 10 + ID in
// info. b0 has the defaults W = 4 and ID = 0; #(8, 2) applies to both b1
// and b2; b3 sets only ID by name and connects seed with .*; b4 is an array
// of two instances with #() whose port gets 8'h0F each.

interface bus_if #(parameter int W = 4, parameter int ID = 0) (input logic [7:0] seed);
  logic [W-1:0] data;
  int info;
  assign data = seed;
  initial info = W * 10 + ID;
endinterface

module test_syntax_interface_instantiation_forms;
  logic [7:0] seed = 8'hA7;

  bus_if b0 (seed);
  bus_if #(8, 2) b1 (.seed(seed)), b2 (8'h3C);
  bus_if #(.ID(5)) b3 (.*);
  bus_if #() b4 [1:0] (8'h0F);

  initial begin
    #1;
    $display("b0: data=%h info=%0d", b0.data, b0.info);
    $display("b1: data=%h info=%0d", b1.data, b1.info);
    $display("b2: data=%h info=%0d", b2.data, b2.info);
    $display("b3: data=%h info=%0d", b3.data, b3.info);
    $display("b4[1]: data=%h info=%0d b4[0]: info=%0d", b4[1].data, b4[1].info, b4[0].info);
  end
endmodule
