/*
:name: test_dpi_coercion_dual_types_and_qualifiers
:description: The SystemVerilog compiler coerces an actual to the declared type of an imported function's formal, the C side supplies matching C types for int, byte, shortint, longint, real, string, packed logic and packed bit, and a rand and a randc property reach C as their unqualified values (IEEE 1800-2023 Sections H.6, H.6.1 and H.7.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.6 H.6.1 H.7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_coercion_dual_types_and_qualifiers.c
:expected_stdout: @test_dpi_coercion_dual_types_and_qualifiers.expected
*/
// IEEE 1800-2023 H.6: the SystemVerilog compiler supplies the coercions the
// actual arguments of an imported call need, the C compiler coerces C types
// from the prototype of an exported subroutine, and both sides declare the
// matching types. H.6.1: a nonopen formal argument has exactly the type and
// range of its import declaration after that coercion. H.6: a qualifier such
// as rand has no representation in the DPI, so its actual arrives in the
// unqualified form. H.7.2: each crossing type has a SystemVerilog definition
// and a matching C definition.
//
// c_types has a byte, a shortint, an int, a longint, a real, a logic [7:0],
// a bit [3:0] and a string formal. The actual 32'h1FF coerced to
// byte is -1, and 32'h12345 coerced to shortint is 9029; the other actuals
// have their formal types. The two packed formals arrive as canonical
// vectors, whose low bits are a5 and 3. c_rand has bit [7:0] and bit [3:0]
// formals, and the rand and randc properties of wA_qual have the values a5
// and 3 when their qualifiers are stripped. The printed values show each
// coercion and each type pair.

`timescale 1ns/1ns

class wA_qual;
  rand bit [7:0] rv;
  randc bit [3:0] rc;

  function new();
    rv = 8'hA5;
    rc = 4'h3;
  endfunction
endclass

module test_dpi_coercion_dual_types_and_qualifiers;
  import "DPI-C" function int c_types(input byte b, input shortint s,
                                      input int i, input longint l,
                                      input real r,
                                      input logic [7:0] lv, input bit [3:0] bv,
                                      input string str);
  import "DPI-C" function int c_rand(input bit [7:0] v, input bit [3:0] c);

  wA_qual q = new();
  int big = 32'h1FF;
  int wide = 32'h12345;

  initial begin
    $display("coerce %0d", c_types(big, wide, -5, 64'sd9000000000, 1.5,
                                  8'hA5, 4'h3, "hi"));
    $display("rand %0d", c_rand(q.rv, q.rc));
  end
endmodule
