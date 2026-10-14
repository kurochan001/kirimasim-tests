/*
:name: test_type_cast_int
:description: Test for integer type casting (IEEE 1800-2023 §6.24)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_cast_int.expected
*/
// Test for integer type casting (IEEE 1800-2023 §6.24)

module test_type_cast_int;
  int i1, i2;
  shortint s1;
  longint l1;
  byte b1;
  logic [31:0] lv;
  real r1;
  int passed;

  initial begin
    passed = 0;

    // Test 1: int to byte cast (truncation)
    $display("Test 1: int to byte cast");
    i1 = 256 + 42;
    b1 = byte'(i1);
    if (b1 == 42) begin
      $display("  PASS: byte'(%0d) = %0d", i1, b1);
      passed++;
    end else begin
      $display("  FAIL: expected 42, got %0d", b1);
    end

    // Test 2: byte to int cast (extension)
    $display("Test 2: byte to int cast");
    b1 = -1;  // 0xFF
    i1 = int'(b1);
    $display("  int'(-1 as byte) = %0d", i1);
    passed++;

    // Test 3: unsigned to signed
    $display("Test 3: unsigned to signed");
    lv = 32'hFFFFFFFF;
    i1 = signed'(lv);
    if (i1 == -1) begin
      $display("  PASS: signed'(0xFFFFFFFF) = %0d", i1);
      passed++;
    end else begin
      $display("  FAIL: expected -1, got %0d", i1);
    end

    // Test 4: signed to unsigned
    $display("Test 4: signed to unsigned");
    i1 = -1;
    lv = unsigned'(i1);
    $display("  unsigned'(-1) = 0x%0x", lv);
    if (lv == 32'hFFFFFFFF) begin
      $display("  PASS");
      passed++;
    end else begin
      $display("  FAIL: result = 0x%0x", lv);
    end

    // Test 5: real to int cast
    $display("Test 5: real to int cast");
    r1 = 3.7;
    i1 = int'(r1);
    $display("  int'(3.7) = %0d", i1);
    if (i1 == 4) begin
      $display("  PASS: rounded to nearest");
      passed++;
    end else begin
      $display("  FAIL: got %0d", i1);
    end

    // Test 6: int to shortint
    $display("Test 6: int to shortint");
    i1 = 70000;
    s1 = shortint'(i1);
    $display("  shortint'(%0d) = %0d", i1, s1);
    passed++;

    // Test 7: longint cast
    $display("Test 7: longint cast");
    l1 = longint'(32'hDEADBEEF);
    $display("  longint'(0xDEADBEEF) = 0x%0x", l1);
    passed++;

    if (passed == 7) begin
      $display("TEST PASSED: %0d/7 tests passed", passed);
    end else begin
      $display("TEST FAILED: %0d/7 tests passed", passed);
    end
    $finish;
  end
endmodule
