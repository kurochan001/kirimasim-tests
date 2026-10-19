/*
:name: test_dpi_logic_values
:description: A logic scalar reaches C as sv_0, sv_1, sv_z or sv_x, and a logic vector as aval and bval words in which 1 is (1,0), z is (0,1) and x is (1,1) (IEEE 1800-2023 Section H.10.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 H.10.1.1 H.10.1.2 H.7.7 H.8.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_logic_values.c
:expected_stdout: @test_dpi_logic_values.expected
*/
// IEEE 1800-2023 H.10.1.1: a scalar logic value is passed as an svLogic whose
// value is sv_0 (0), sv_1 (1), sv_z (2) or sv_x (3). H.7.7, H.10.1.2: a packed
// 4-state array is passed as svLogicVecVal words, each with an aval and a bval
// word; a bit is 0 for (0,0), 1 for (1,0), z for (0,1) and x for (1,1). The
// unused bits above bit 3 are masked in C (H.7.7). H.8.8: the output vector is
// passed by reference. Verilator 5.052, a two-state simulator, does not support
// x and z values in DPI arguments, and Icarus Verilog 13.0 has no DPI.

module test_dpi_logic_values;
  import "DPI-C" function int dpi_code(input logic l);
  import "DPI-C" function void dpi_make(output logic [3:0] v);
  import "DPI-C" function void dpi_planes(input logic [3:0] v, output int a, output int b);

  initial begin
    logic [3:0] v;
    int a, b;
    $display("codes: %0d %0d %0d %0d", dpi_code(1'b0), dpi_code(1'b1), dpi_code(1'bz), dpi_code(1'bx));
    dpi_make(v);
    $display("made: %b", v);
    dpi_planes(4'b1x0z, a, b);
    $display("planes of 1x0z: aval=%b bval=%b", a[3:0], b[3:0]);
  end
endmodule
