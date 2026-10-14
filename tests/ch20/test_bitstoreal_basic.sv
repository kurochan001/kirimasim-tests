/*
:name: test_bitstoreal_basic
:description: Test $bitstoreal basic (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitstoreal_basic.expected
*/
// Test $bitstoreal basic (IEEE 1800-2023 Section 20.5)

module test_bitstoreal_basic;
  real r;
  logic [63:0] bits;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Convert from 0
    bits = 64'h0;
    r = $bitstoreal(bits);
    if (r == 0.0) pass_count++;

    // Test 2: Round-trip test
    r = 3.14;
    bits = $realtobits(r);
    r = $bitstoreal(bits);
    if (r > 3.13 && r < 3.15) pass_count++;

    // Test 3: Another value
    r = -1.0;
    bits = $realtobits(r);
    r = $bitstoreal(bits);
    if (r == -1.0) pass_count++;

    $display("Bitstoreal basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Bitstoreal basic tests");
    end else begin
      $display("FAIL: Some bitstoreal tests failed");
    end
  end
endmodule
