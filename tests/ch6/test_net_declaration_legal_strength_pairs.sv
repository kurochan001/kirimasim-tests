/*
:name: test_net_declaration_legal_strength_pairs
:description: every permitted drive-strength pair form is accepted and supplies the stated strength to its net
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_declaration_legal_strength_pairs.expected
*/
// IEEE 1800-2023 6.7: a drive_strength is (strength0, strength1),
// (strength1, strength0), (strength0, highz1), (strength1, highz0),
// (highz0, strength1) or (highz1, strength0), so the two sides may come in
// either order and at most one side is the matching high-impedance form.
// Each of the six forms is declared once with constants driving both values;
// %v prints the resulting value and strength. A tool that rejects a permitted
// order, or swaps the 0 and 1 sides, prints another strength or another value.

module test_net_declaration_legal_strength_pairs;
  wire (strong0, strong1) a = 1'b0;
  wire (strong1, strong0) b = 1'b1;
  wire (pull0, pull1) c = 1'b0;
  wire (supply1, supply0) d = 1'b1;
  wire (highz0, weak1) e = 1'b1;
  wire (weak0, highz1) f = 1'b0;
  wire (highz1, supply0) g = 1'b1;
  wire (supply1, highz0) h = 1'b0;

  initial
    #1 $display("a=%v b=%v c=%v d=%v e=%v f=%v g=%v h=%v",
                a, b, c, d, e, f, g, h);
endmodule
