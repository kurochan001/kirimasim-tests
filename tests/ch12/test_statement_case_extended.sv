/*
:name: test_statement_case_extended
:description: Test for case statement extended (IEEE 1800-2023 §12.5)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_case_extended.expected
*/
// Test for case statement extended (IEEE 1800-2023 §12.5)

module test_statement_case_extended;
  int val;
  string result;
  int passed;

  initial begin
    passed = 0;

    // Test 1: Simple case
    $display("Test 1: Simple case");
    val = 2;
    case (val)
      0: result = "zero";
      1: result = "one";
      2: result = "two";
      3: result = "three";
      default: result = "other";
    endcase
    if (result == "two") begin
      $display("  PASS: case(2) = %s", result);
      passed++;
    end else begin
      $display("  FAIL: expected 'two', got '%s'", result);
    end

    // Test 2: Default case
    $display("Test 2: Default case");
    val = 99;
    case (val)
      0: result = "zero";
      1: result = "one";
      default: result = "default";
    endcase
    if (result == "default") begin
      $display("  PASS: case(99) = %s", result);
      passed++;
    end else begin
      $display("  FAIL: expected 'default', got '%s'", result);
    end

    // Test 3: Multiple values per case
    $display("Test 3: Multiple values per case");
    val = 5;
    case (val)
      1, 3, 5, 7, 9: result = "odd";
      0, 2, 4, 6, 8: result = "even";
      default: result = "other";
    endcase
    if (result == "odd") begin
      $display("  PASS: case(5) = %s", result);
      passed++;
    end else begin
      $display("  FAIL: expected 'odd', got '%s'", result);
    end

    // Test 4: Nested case
    $display("Test 4: Nested case");
    begin
      int a, b;
      a = 1;
      b = 2;
      case (a)
        0: result = "a=0";
        1: case (b)
             1: result = "a=1,b=1";
             2: result = "a=1,b=2";
             default: result = "a=1,b=?";
           endcase
        default: result = "a=?";
      endcase
      if (result == "a=1,b=2") begin
        $display("  PASS: nested = %s", result);
        passed++;
      end else begin
        $display("  FAIL: expected 'a=1,b=2', got '%s'", result);
      end
    end

    // Test 5: Case with expression
    $display("Test 5: Case with expression");
    val = 10;
    case (val + 5)
      10: result = "ten";
      15: result = "fifteen";
      20: result = "twenty";
      default: result = "other";
    endcase
    if (result == "fifteen") begin
      $display("  PASS: case(10+5) = %s", result);
      passed++;
    end else begin
      $display("  FAIL: expected 'fifteen', got '%s'", result);
    end

    if (passed == 5) begin
      $display("TEST PASSED: %0d/5 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/5 tests passed", passed);
    end
    $finish;
  end
endmodule
