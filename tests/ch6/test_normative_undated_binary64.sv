/*
:name: test_normative_undated_binary64
:description: Binary64 subnormal arithmetic, rounding, and signed zero follow the IEEE 754 reference
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12.1 2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: normative_reference_editions/publishers.json normative_reference_editions/undated.expected
:expected_stdout: @test_normative_undated_binary64.expected
*/
module test_normative_undated_binary64;
  real least, unity, half_ulp, negzero;
  initial begin
    least = $bitstoreal(64'h0000000000000001);
    unity = $bitstoreal(64'h3ff0000000000000);
    half_ulp = $bitstoreal(64'h3ca0000000000000);
    negzero = $bitstoreal(64'h8000000000000000);
    $display("subnormal=%016h sum=%016h", $realtobits(least), $realtobits(least + least));
    $display("tie=%016h negative-zero=%016h", $realtobits(unity + half_ulp), $realtobits(negzero));
    $finish(0);
  end
endmodule
