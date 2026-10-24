/*
:name: test_param_type_range_after_override
:description: after an override, a parameter without type or range takes the type and [size-1:0] range of its final value, a range-only parameter stays unsigned with its range, a signed-only parameter takes the size of the final value, a typed or signed ranged one keeps its type, and real and integer values convert as in assignments (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 6.12.1 23.10.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_param_type_range_after_override.expected
*/
// IEEE 1800-2023 §6.20.2, for the final value after overrides:
//   no type or range (PU, PUR): the type of the final value; a real value
//   gives a real parameter, an integral one a logic vector of its size with
//   range [size-1:0], so bit 0 is the LSB and 4'b1x0z keeps its x and z;
//   range only (PR): unsigned with the declared range, whatever the value;
//   signed only (PS): signed, with the range [size-1:0] of the final value;
//   type only (PI, PIR, PRL): the declared type;
//   signed with a range (PSR): signed with the declared range.
// Real and integer values convert as in §6.12.1: -2.5 and 2.5 round away
// from zero to -3 and 3. The top module reads both instances by name.

module prt_child #(
  parameter PU = 1,
  parameter PUR = 1,
  parameter [7:0] PR = 1,
  parameter signed PS = 1,
  parameter signed [7:0] PSR = 1,
  parameter int PI = 1,
  parameter int PIR = 1,
  parameter real PRL = 1.5
) ();
endmodule

module test_param_type_range_after_override;
  prt_child #(.PU(6'b100110), .PUR(2.5), .PR(-1), .PS(16'hfff0), .PSR(12'h0f0),
              .PI(8'hff), .PIR(-2.5), .PRL(7)) c1 ();
  prt_child #(.PU(4'b1x0z), .PR(16'habcd), .PS(3'sb101), .PSR(-200), .PI(-1),
              .PIR(2.5), .PRL(2)) c2 ();

  initial begin
    $display("c1 PU=%0d bits=%0d [5]=%b [0]=%b neg=%0d PUR=%0.2f", c1.PU, $bits(c1.PU),
             c1.PU[5], c1.PU[0], c1.PU < 0, c1.PUR);
    $display("c1 PR=%0d bits=%0d neg=%0d", c1.PR, $bits(c1.PR), c1.PR < 0);
    $display("c1 PS=%0d bits=%0d [15]=%b [0]=%b neg=%0d", c1.PS, $bits(c1.PS), c1.PS[15],
             c1.PS[0], c1.PS < 0);
    $display("c1 PSR=%0d bits=%0d PI=%0d bits=%0d PIR=%0d PRL=%0.2f", c1.PSR, $bits(c1.PSR),
             c1.PI, $bits(c1.PI), c1.PIR, c1.PRL);
    $display("c2 PU=%b bits=%0d", c2.PU, $bits(c2.PU));
    $display("c2 PR=%0d bits=%0d PS=%0d bits=%0d [2]=%b", c2.PR, $bits(c2.PR), c2.PS,
             $bits(c2.PS), c2.PS[2]);
    $display("c2 PSR=%0d bits=%0d PI=%0d PIR=%0d PRL=%0.2f", c2.PSR, $bits(c2.PSR), c2.PI,
             c2.PIR, c2.PRL);
  end
endmodule
