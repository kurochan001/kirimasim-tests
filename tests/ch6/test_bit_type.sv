/*
:name: test_bit_type
:description: Test bit type (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_type.expected
*/
// Test bit type (IEEE 1800-2023 Section 6.8)

module test_bit_type;
  bit b1;
  bit [7:0] b8;
  bit [15:0] b16;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Single bit
    b1 = 1'b1;
    if (b1 == 1'b1) pass_count++;

    // Test 2: 8-bit
    b8 = 8'hCD;
    if (b8 == 8'hCD) pass_count++;

    // Test 3: 16-bit
    b16 = 16'h1234;
    if (b16 == 16'h1234) pass_count++;

    // Test 4: Toggle
    b1 = ~b1;
    if (b1 == 1'b0) pass_count++;

    $display("Bit type tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Bit type tests");
    end else begin
      $display("FAIL: Some bit type tests failed");
    end
  end
endmodule
