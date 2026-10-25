/*
:name: test_interface_generate_items
:description: A generate construct in an interface declares interface items only, here a variable and a continuous assignment in each of two generated blocks; each block adds its genvar to the interface variable, so the two generated variables are 1 and 2 (IEEE 1800-2023 Sections 27.2 and 27.3 and footnote 35 of A.10)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.3 27.2 25.3 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_generate_items.expected
*/
// IEEE 1800-2023 footnote 35 of A.10: in an interface declaration a generate
// item is an interface_or_generate_item; the same footnote restricts a module
// generate item to module_or_generate_item and a checker generate item to
// checker_or_generate_item. §27.2: a generate construct creates one or more
// blocks. §27.3: the loop generate construct repeats a block for each value
// of its genvar; the block declares an interface variable and the continuous
// assignment that drives it, both interface items. §25.3: an interface
// declares variables and continuous assignments in its body.
//
// The interface instance bus has d = 4'h1 and two generated blocks, so
// bus.gi[0].w is 1 + 0 = 1 and bus.gi[1].w is 1 + 1 = 2.
//
// Icarus Verilog 13.0 and Verilator 5.052 produce this output.

`timescale 1ns/1ns

interface gen_ifc;
  logic [3:0] d;

  for (genvar i = 0; i < 2; i++) begin : gi
    logic [3:0] w;
    assign w = d + i;
  end
endinterface

module test_interface_generate_items;
  gen_ifc bus ();

  initial begin
    bus.d = 4'h1;
    #1 $display("iface %h %h", bus.gi[0].w, bus.gi[1].w);
  end
endmodule
