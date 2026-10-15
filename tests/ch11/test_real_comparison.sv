/*
:name: test_real_comparison
:description: Relational and equality operators on real values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_comparison.expected
*/
// Relational and equality operators on real values
module test_real_comparison;

  initial begin
    real a, b;
    static int pass_count = 0;

    $display("=== Real Comparison Test ===");

    // Test 1: Equal
    a = 3.5;
    b = 3.5;
    if (a == b) begin
      $display("[PASS] Equal: %f == %f", a, b);
      pass_count++;
    end else begin
      $display("[FAIL] Equal: %f should == %f", a, b);
    end

    // Test 2: Not equal
    a = 2.5;
    b = 3.5;
    if (a != b) begin
      $display("[PASS] Not equal: %f != %f", a, b);
      pass_count++;
    end else begin
      $display("[FAIL] Not equal: %f should != %f", a, b);
    end

    // Test 3: Less than
    a = 2.3;
    b = 4.5;
    if (a < b) begin
      $display("[PASS] Less than: %f < %f", a, b);
      pass_count++;
    end else begin
      $display("[FAIL] Less than: %f should < %f", a, b);
    end

    // Test 4: Greater than
    a = 5.8;
    b = 3.2;
    if (a > b) begin
      $display("[PASS] Greater than: %f > %f", a, b);
      pass_count++;
    end else begin
      $display("[FAIL] Greater than: %f should > %f", a, b);
    end

    // Test 5: Less or equal
    a = 3.5;
    b = 3.5;
    if (a <= b) begin
      $display("[PASS] Less or equal: %f <= %f", a, b);
      pass_count++;
    end else begin
      $display("[FAIL] Less or equal: %f should <= %f", a, b);
    end

    // Test 6: Greater or equal
    a = 4.5;
    b = 3.5;
    if (a >= b) begin
      $display("[PASS] Greater or equal: %f >= %f", a, b);
      pass_count++;
    end else begin
      $display("[FAIL] Greater or equal: %f should >= %f", a, b);
    end

    // Test 7: Mixed real and int comparison
    a = 5.0;
    if (a == 5) begin
      $display("[PASS] Real-int equal: %f == 5", a);
      pass_count++;
    end else begin
      $display("[FAIL] Real-int equal: %f should == 5", a);
    end

    $display("\n=== Summary: %0d/7 tests passed ===", pass_count);

    $finish;
  end

endmodule
