/*
:name: test_real_boolean_results_without_shortreal
:description: Isolate real logical, relational and inside result widths from shortreal support
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.1 11.4.13 20.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_boolean_results_without_shortreal.expected
*/
// IEEE 11.3.1: logical/relational/inside results on real operands
// each have one bit. Isolating this from shortreal makes this rule
// executable on a tool that supports real inside but widens shortreal.
// Icarus 13.0 rejects inside expressions as unsupported.
module test_real_boolean_results_without_shortreal;
  real a = 1.5, b = 0.25;
  initial begin
    $display("bits=%0d %0d %0d %0d %0d",
             $bits(a<b), $bits(a>=b), $bits(a&&b),
             $bits(a||b), $bits(a inside {0.5, 1.5, 2.5}));
    $display("values=%b %b %b %b %b", a<b, a>=b, a&&b, a||b,
             a inside {0.5, 1.5, 2.5});
    $finish;
  end
endmodule
