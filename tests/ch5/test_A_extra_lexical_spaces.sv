/*
:name: test_A_extra_lexical_spaces
:description: A simple identifier, a system task identifier, an unbased unsized literal and a time literal are written without embedded white space, so a$b, $display, '0 and 10ns are each one token (IEEE 1800-2023 Sections 5.6, 5.7 and 5.9, A.10)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 5.7 5.9 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_lexical_spaces.expected
*/
// IEEE 1800-2023 A.10, clarification 38: embedded spaces are illegal at the
// grammar sites that footnote 38 marks. §5.6 makes a simple identifier start
// with a letter or underscore and continue with letters, digits, underscores
// or dollar signs, so a$b is one identifier. §5.6 and clarification 55 make a
// system task identifier start with $ and continue without white space, so
// $display is one token. §5.7 and clarification 53 make an unbased unsized
// literal a single apostrophe and one character with no space, so '0 is one
// token. §5.7 and clarification 49 make the number and the unit of a time
// literal adjacent, so 10ns is one token.
//
// The identifier a$b starts at '0, receives 5A after 10ns, and $time at that
// point is 10, so the line prints a=5a t=10.

`timescale 1ns/1ps
module test_A_extra_lexical_spaces;
  logic [7:0] a$b = '0;

  initial begin
    #10ns a$b = 8'h5a;
    $display("a=%h t=%0d", a$b, $time);
  end
endmodule
