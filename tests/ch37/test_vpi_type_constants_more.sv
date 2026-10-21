/*
:name: test_vpi_type_constants_more
:description: vpi_get_str(vpiType) names the type constant of ports, named forks, system task and function calls, user systf objects, iterators, callbacks, expressions, generate scopes, primitives, continuous assignments and timing checks; vpiPrimType, vpiOpType and vpiTchkType give their constant names too; vpiIsProtected is false for all of them (IEEE 1800-2023 Section 37.3.2)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.2 37.3.6 37.3.1 37.14 37.12 37.42 37.84 37.80 37.85 37.59 37.35 37.36 37.40 37.47
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_type_constants_more.c
:expected_stdout: @test_vpi_type_constants_more.expected
*/
// IEEE 1800-2023 §37.3.2: every object has vpiType; vpi_get gives the type
// constant and vpi_get_str the name of that constant, derived from the name of
// the object in its diagram. For objects that test_vpi_type_strings does not
// cover (a port 37.14, a named fork 37.12, the system task call, its user systf
// object and arguments 37.42 and 37.59, an iterator 37.3.1 and 37.84, a
// callback 37.80, a gen scope array and gen scope 37.85, primitives and a prim
// term 37.35, a UDP definition 37.36, a continuous assignment 37.47, a timing
// check and its reference term 37.40), the application prints the string and
// whether vpi_get gives the constant of that object kind. The additional type
// properties vpiPrimType, vpiOpType and vpiTchkType also give the name of their
// constant through vpi_get_str: vpiAndPrim and vpiBufif1Prim for the gates,
// vpiSeqPrim for the definition of a sequential UDP (37.36 detail 2), vpiAddOp
// for a + and vpiSetup for a $setup (Annex K). §37.3.6: vpiIsProtected, which
// every object has, is false here, as nothing is protected.

`timescale 1ns/1ns

primitive test_vpi_type_constants_more_latch(output reg q, input en, d);
  table
    1 1 : ? : 1;
    1 0 : ? : 0;
    0 ? : ? : -;
  endtable
endprimitive

module test_vpi_type_constants_more_ff(input wire clk, input wire d, output reg q);
  always @(posedge clk) q <= d;
  specify
    $setup(d, posedge clk, 1);
  endspecify
endmodule

module test_vpi_type_constants_more;
  logic [3:0] r = 4'b1010;
  logic clk = 0, a2 = 1, b2 = 0, n = 0;
  wire yand, ybuf, yq, yff, ycont;

  and ga (yand, r[0], r[1]);
  bufif1 gb (ybuf, r[2], r[3]);
  test_vpi_type_constants_more_latch lu (yq, r[1], r[0]);
  test_vpi_type_constants_more_ff u (clk, r[3], yff);
  assign ycont = r[0] ^ r[3];

  for (genvar i = 0; i < 2; i++) begin : g
    wire gl;
    assign gl = r[i];
  end

  initial fork : fk
    #1 n = 1;
  join

  initial begin
    #2 $vt_types($time, 5, r[3:1], a2 + b2);
  end
endmodule
