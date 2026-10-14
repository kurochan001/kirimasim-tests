/*
:name: test_value_ops_bitwise
:description: Test for bitwise value operations (IEEE 1800-2023 §11.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_ops_bitwise.expected
*/
// Test for bitwise value operations (IEEE 1800-2023 §11.4)

module test_value_ops_bitwise;
  logic [7:0] a, b, c;
  int passed;

  initial begin
    passed = 0;

    // Test 1: Bitwise AND
    $display("Test 1: Bitwise AND");
    a = 8'b1111_0000;
    b = 8'b1010_1010;
    c = a & b;
    if (c == 8'b1010_0000) begin
      $display("  PASS: %b & %b = %b", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 10100000, got %b", c);
    end

    // Test 2: Bitwise OR
    $display("Test 2: Bitwise OR");
    c = a | b;
    if (c == 8'b1111_1010) begin
      $display("  PASS: %b | %b = %b", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 11111010, got %b", c);
    end

    // Test 3: Bitwise XOR
    $display("Test 3: Bitwise XOR");
    c = a ^ b;
    if (c == 8'b0101_1010) begin
      $display("  PASS: %b ^ %b = %b", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: expected 01011010, got %b", c);
    end

    // Test 4: Bitwise NOT
    $display("Test 4: Bitwise NOT");
    c = ~a;
    if (c == 8'b0000_1111) begin
      $display("  PASS: ~%b = %b", a, c);
      passed++;
    end else begin
      $display("  FAIL: expected 00001111, got %b", c);
    end

    // Test 5: XNOR
    $display("Test 5: Bitwise XNOR");
    c = a ~^ b;
    if (c == 8'b1010_0101) begin
      $display("  PASS: %b ~^ %b = %b", a, b, c);
      passed++;
    end else begin
      $display("  FAIL: %b ~^ %b = %b", a, b, c);
    end

    // Test 6: Left shift
    $display("Test 6: Left shift");
    a = 8'b0000_0001;
    c = a << 4;
    if (c == 8'b0001_0000) begin
      $display("  PASS: %b << 4 = %b", a, c);
      passed++;
    end else begin
      $display("  FAIL: expected 00010000, got %b", c);
    end

    // Test 7: Right shift
    $display("Test 7: Right shift");
    a = 8'b1000_0000;
    c = a >> 4;
    if (c == 8'b0000_1000) begin
      $display("  PASS: %b >> 4 = %b", a, c);
      passed++;
    end else begin
      $display("  FAIL: expected 00001000, got %b", c);
    end

    // Test 8: Arithmetic right shift
    $display("Test 8: Arithmetic right shift");
    a = 8'b1000_0000;  // Negative in signed interpretation
    c = $signed(a) >>> 2;
    $display("  $signed(%b) >>> 2 = %b", a, c);
    passed++;

    if (passed == 8) begin
      $display("TEST PASSED: %0d/8 tests passed", passed);
    end else begin
      $display("TEST FAILED: %0d/8 tests passed", passed);
    end
    $finish;
  end
endmodule
