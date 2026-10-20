/*
:name: test_gate_declaration_instances
:description: A gate declaration starts with the keyword of its primitive and can declare several instances, named or not, which all use that primitive (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.3.4 28.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_declaration_instances.expected
*/
// IEEE 1800-2023 §28.3.1: a gate or switch declaration begins with the
// keyword of the primitive (Table 28-1), and the instances that follow in the
// declaration all use it. §28.3.4: the name of an instance is optional. One
// nand declaration has the named instances g1 and g2 and an unnamed third;
// one xor declaration has two unnamed instances.

`timescale 1ns/1ns

module test_gate_declaration_instances;
  logic a = 0, b = 0, c = 0;
  wire n1, n2, n3, x1, x2;

  nand g1 (n1, a, b), g2 (n2, b, c), (n3, a, c);
  xor (x1, a, b), (x2, n1, c);

  initial begin
    a = 1;
    b = 1;
    #1 $display("nand: %b %b %b, xor: %b %b", n1, n2, n3, x1, x2);
  end
endmodule
