/*
:name: test_wire_tri_resolution_table
:description: Two drivers of equal strength on a wire and on a tri resolve by the same table for all 16 pairs of 0, 1, x and z, with x for every conflict (IEEE 1800-2023 Section 6.6.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 28.12 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wire_tri_resolution_table.expected
*/
// IEEE 1800-2023 §6.6.1: wire and tri are the same net type under two names,
// and two drivers of the same strength resolve by its truth table: equal
// values give that value, z gives way to the other driver, and every other
// pair (0 with 1, or anything with x) gives x. The nets w and t each have two
// strong continuous assignments from a and b, and ww has two weak ones, so a
// conflict at weak strength is shown too. Every pair of 0, 1, x and z is
// driven, in both orders, and each line shows the values with %b and the
// strengths with %v (21.2.1.4, 28.12): a strong x is StX, a weak one WeX, and
// two z drivers leave the net at HiZ.

module test_wire_tri_resolution_table;
  logic a, b;
  logic [3:0] vals = 4'bzx10;   // vals[0..3] = 0, 1, x, z
  wire w;
  tri t;
  wire ww;

  assign w = a;
  assign w = b;
  assign t = a;
  assign t = b;
  assign (weak0, weak1) ww = a;
  assign (weak0, weak1) ww = b;

  initial begin
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++) begin
        a = vals[i];
        b = vals[j];
        #1 $display("%b%b wire=%b %v tri=%b %v weak=%v", a, b, w, w, t, t, ww);
      end
  end
endmodule
