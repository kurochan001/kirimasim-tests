/*
:name: test_enum_edge
:description: Enum edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5 6.19.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_edge.expected
*/
// IEEE 1800-2023 §6.19: Enum edge cases
`timescale 1ns/1ps

module test_enum_edge;
  // Basic enum
  typedef enum {RED, GREEN, BLUE} color_t;

  // Enum with explicit values
  typedef enum int {A=1, B=5, C=10, D=15} sparse_t;

  // Enum with negative values
  typedef enum int signed {NEG=-10, ZERO=0, POS=10} signed_t;

  // Enum with bit type
  typedef enum bit [3:0] {S0=0, S1=1, S2=2, S3=3, S4=4} state_t;

  color_t c, c2;
  sparse_t s;
  signed_t sg;
  state_t st;
  int i;
  bit test_passed;

  initial begin
    test_passed = 1;

    // Test 1: Default value
    c = RED;
    if (c != RED) begin
      $display("FAIL: Default enum assignment failed");
      test_passed = 0;
    end

    // Test 2: first() method
    c = c.first();
    if (c != RED) begin
      $display("FAIL: first() should return RED");
      test_passed = 0;
    end

    // Test 3: last() method
    c = c.last();
    if (c != BLUE) begin
      $display("FAIL: last() should return BLUE");
      test_passed = 0;
    end

    // Test 4: next() method
    c = RED;
    c = c.next();
    if (c != GREEN) begin
      $display("FAIL: RED.next() should be GREEN");
      test_passed = 0;
    end

    // Test 5: next() wrap around
    c = BLUE;
    c = c.next();
    if (c != RED) begin
      $display("FAIL: BLUE.next() should wrap to RED");
      test_passed = 0;
    end

    // Test 6: prev() method
    c = GREEN;
    c = c.prev();
    if (c != RED) begin
      $display("FAIL: GREEN.prev() should be RED");
      test_passed = 0;
    end

    // Test 7: prev() wrap around
    c = RED;
    c = c.prev();
    if (c != BLUE) begin
      $display("FAIL: RED.prev() should wrap to BLUE");
      test_passed = 0;
    end

    // Test 8: num() method
    i = c.num();
    if (i != 3) begin
      $display("FAIL: color_t.num() should be 3, got %0d", i);
      test_passed = 0;
    end

    // Test 9: name() method
    c = GREEN;
    if (c.name() != "GREEN") begin
      $display("FAIL: GREEN.name() should be 'GREEN', got '%s'", c.name());
      test_passed = 0;
    end

    // Test 10: Sparse enum
    s = A;
    if (s != 1) begin
      $display("FAIL: A should equal 1");
      test_passed = 0;
    end
    s = s.next();
    if (s != B) begin
      $display("FAIL: A.next() should be B");
      test_passed = 0;
    end

    // Test 11: Signed enum basic assignment
    sg = NEG;
    if (sg != -10) begin
      $display("FAIL: NEG should be -10");
      test_passed = 0;
    end
    sg = ZERO;
    if (sg != 0) begin
      $display("FAIL: ZERO should be 0");
      test_passed = 0;
    end
    sg = POS;
    if (sg != 10) begin
      $display("FAIL: POS should be 10");
      test_passed = 0;
    end

    // Test 12: Cast int to enum
    c = color_t'(1);
    if (c != GREEN) begin
      $display("FAIL: color_t'(1) should be GREEN");
      test_passed = 0;
    end

    // Test 13: Cast enum to int
    c = BLUE;
    i = int'(c);
    if (i != 2) begin
      $display("FAIL: int'(BLUE) should be 2");
      test_passed = 0;
    end

    // Test 14: Enum comparison
    c = RED;
    c2 = RED;
    if (c != c2) begin
      $display("FAIL: RED should equal RED");
      test_passed = 0;
    end
    c2 = GREEN;
    if (c == c2) begin
      $display("FAIL: RED should not equal GREEN");
      test_passed = 0;
    end

    // Test 15: next(N) - multiple steps
    c = RED;
    c = c.next(2);
    if (c != BLUE) begin
      $display("FAIL: RED.next(2) should be BLUE");
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Enum edge cases");
    end else begin
      $display("FAIL: Some enum tests failed");
    end
    $finish;
  end
endmodule
