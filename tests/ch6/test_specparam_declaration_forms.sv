/*
:name: test_specparam_declaration_forms
:description: specparam declarations with and without a packed range, with lists of assignments and a min:typ:max value, in a module body and in a specify block where one gives a path delay (IEEE 1800-2023 Sections 6.20.5, A.2.1.1, A.2.3, A.2.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5 A.2.1.1 A.2.3 A.2.4 30.4.1 11.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_declaration_forms.expected
*/
// IEEE 1800-2023 A.2.1.1: a specparam declaration is the keyword specparam,
// an optional packed dimension, a list of specparam assignments and a
// semicolon; A.2.3 and A.2.4: the list has one or more comma-separated
// entries, each a name, =, and a constant min:typ:max expression (§11.11).
// §6.20.5: specparams can be declared in the module body and in a specify
// block and used in expressions; one with a range has that range, one without
// a range has the range of its value, and a later specparam can use an
// earlier one.
// - SP_A and SP_B share the range [7:0]: SP_A = 300 keeps the low 8 bits, 44,
//   and SP_B = SP_A + 1 is 45;
// - SP_C = 4'd9 has no range and is 4 bits wide; SP_R = 2.5 is real;
// - in the specify block of spb_cell, tPD = 3:3:3 (the same value whichever
//   of the three is selected) and tSLOW = tPD + 2 form one list, and tPD is
//   the delay of the path a => y (§30.4.1), so y follows a 3 time units
//   later; tSLOW is printed through a function of the cell.

`timescale 1ns/1ns

module spb_cell (input a, output y);
  buf (y, a);

  specify
    specparam tPD = 3:3:3, tSLOW = tPD + 2;
    (a => y) = tPD;
  endspecify

  function int slow();
    return tSLOW;
  endfunction
endmodule

module test_specparam_declaration_forms;
  specparam [7:0] SP_A = 300, SP_B = SP_A + 1;
  specparam SP_C = 4'd9, SP_R = 2.5;

  reg a = 0;
  wire y;

  spb_cell u (a, y);

  initial begin
    $display("SP_A=%0d SP_B=%0d bits(SP_A)=%0d bits(SP_B)=%0d", SP_A, SP_B, $bits(SP_A),
             $bits(SP_B));
    $display("SP_C=%0d bits(SP_C)=%0d SP_R=%0.1f tSLOW=%0d", SP_C, $bits(SP_C), SP_R, u.slow());
    #10 a = 1;
    #2 $display("t=%0t y=%b", $time, y);
    #2 $display("t=%0t y=%b", $time, y);
  end
endmodule
