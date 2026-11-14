/*
:name: test_definitions_visible_from_other_file
:description: A package, an interface, a primitive, a module and a program declared in another source file are all found by name from the test's file, whether the two files form one compilation unit or two (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 3.12
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: definitions_visible_from_other_file_defs.sv
:expected_stdout: @test_definitions_visible_from_other_file.expected
*/
// IEEE 1800-2023 §3.12.1: modules, primitives, programs, interfaces and
// packages are visible in all compilation units, unlike the declarations of
// a compilation-unit scope. §3.12: a design can be compiled from several
// files, and a package is compiled before it is referenced; the file that
// :files: names is compiled first.
// All five definitions come from that file, and the test's file uses each
// of them by name: it imports the package dvo_pkg (DVO_K = 5 and the
// function dvo_twice), instantiates the interface dvo_bus and sets its v to
// dvo_twice(5) = 10, instantiates the primitive dvo_inv, an inverter whose
// input a is 0, the module dvo_add, which adds DVO_K to v, and the program
// dvo_report, which prints the sum at 3. The module prints at 1:
// K=5 twice=10, y=1, v=10 and sum=15; the program then prints 15. When the
// last program ends, the simulation ends.
// Icarus Verilog 13.0 and the 5.054 release of Verilator produce this output.

module test_definitions_visible_from_other_file;
  import dvo_pkg::*;

  logic a = 1'b0;
  wire y;
  logic [7:0] sum;

  dvo_bus bus ();
  dvo_inv g (y, a);
  dvo_add u (.i(bus.v), .o(sum));
  dvo_report p (.v(sum));

  initial begin
    bus.v = dvo_twice(DVO_K);
    #1 $display("package: K=%0d twice=%0d", DVO_K, dvo_twice(DVO_K));
    $display("primitive: a=%b y=%b", a, y);
    $display("interface and module: v=%0d sum=%0d", bus.v, sum);
  end
endmodule
