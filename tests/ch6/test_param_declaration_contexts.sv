/*
:name: test_param_declaration_contexts
:description: parameter and localparam declarations appear in a module, interface, program, class and package, in their parameter port lists, in a generate block and in the compilation unit, where parameter means localparam (IEEE 1800-2023 Sections 6.20.1 and 6.20.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 6.20.4 6.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_declaration_contexts.expected
*/
// IEEE 1800-2023 §6.20.1: parameter assignments can appear in a module,
// interface, program, class or package, and in the parameter port list of a
// module, interface, program or class. §6.20.4: a localparam can also be
// declared in a generate block, a package, a class body or the compilation
// unit, and there the parameter keyword is a synonym for localparam. Each
// context below declares a parameter (and in the four local contexts both
// keywords); the values are read back from the top module and, for the
// program, printed by the program itself at time 2.
// Icarus Verilog 13.0 does not parse parameterized classes (unsupported
// construct).

parameter int CU_P = 1;
localparam int CU_L = 2;

package pdc_pkg;
  parameter int PK_P = 3;
  localparam int PK_L = 4;
endpackage

interface pdc_if #(int IP = 5) ();
  parameter int IB = 6;
endinterface

program pdc_prog #(int GP = 7) ();
  parameter int GB = 8;
  initial #2 $display("program: GP=%0d GB=%0d", GP, GB);
endprogram

class pdc_c #(int CP = 9);
  parameter int CB = 10;
  localparam int CL = CP + 1;
endclass

module pdc_m;
  parameter int MB = 12;
  if (1) begin : g
    parameter int GEN_P = 13;
    localparam int GEN_L = GEN_P + MB;
  end
endmodule

module pdc_pm #(int MP = 15) ();
endmodule

module test_param_declaration_contexts;
  pdc_if #(50) i ();
  pdc_prog #(70) p ();
  pdc_m m ();
  pdc_pm #(150) pm ();

  initial begin
    #1;
    $display("unit: %0d %0d", CU_P, CU_L);
    $display("package: %0d %0d", pdc_pkg::PK_P, pdc_pkg::PK_L);
    $display("interface: IP=%0d IB=%0d", i.IP, i.IB);
    $display("class: CP=%0d CB=%0d CL=%0d", pdc_c#(90)::CP, pdc_c#(90)::CB, pdc_c#(90)::CL);
    $display("module: MB=%0d GEN_P=%0d GEN_L=%0d MP=%0d", m.MB, m.g.GEN_P, m.g.GEN_L, pm.MP);
  end
endmodule
