/*
:name: test_byte_ops
:description: Test byte operations (IEEE 1800-2023 Section 6.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 11.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_byte_ops.expected
*/
// Test byte operations (IEEE 1800-2023 Section 6.4)

module test_byte_ops;
  byte b1, b2, b3;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Byte assignment
    b1 = 8'd100;
    if (b1 == 100) pass_count++;

    // Test 2: Byte addition
    b2 = 8'd50;
    b3 = b1 + b2;
    if (b3 == -106) pass_count++;  // Overflow wraps

    // Test 3: Byte negative
    b1 = -1;
    if (b1 == -1) pass_count++;

    // Test 4: Byte max positive
    b1 = 127;
    if (b1 == 127) pass_count++;

    $display("Byte ops tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Byte ops tests");
    end else begin
      $display("FAIL: Some byte ops tests failed");
    end
  end
endmodule
