/*
:name: test_lexical_identifiers
:description: Test for IEEE 1800-2023 Chapter 5.6: Identifiers and keywords
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_lexical_identifiers.expected
*/
// Test for IEEE 1800-2023 Chapter 5.6: Identifiers and keywords
// Tests simple identifiers, case sensitivity, and underscore usage

module test_lexical_identifiers;
  int pass_count;
  int fail_count;

  // Simple identifiers with underscores
  reg a_b_c;
  reg _leading_underscore;

  // Case-sensitive identifiers
  reg [1:0] Value;
  reg [1:0] value;
  reg [1:0] VALUE;

  // Long identifier
  reg this_is_a_very_long_identifier_name_for_testing_purposes;

  // Identifiers with numbers
  reg var1;
  reg var2;
  reg data_8bit;

  initial begin
    pass_count = 0;
    fail_count = 0;
    $display("=== IEEE 1800-2023 Section 5.6: Identifiers ===");

    // Test 1: Identifiers with underscores
    a_b_c = 1;
    _leading_underscore = 1;
    if (a_b_c && _leading_underscore) begin
      $display("PASS: Test 1 - Underscore identifiers");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Underscore identifiers");
      fail_count++;
    end

    // Test 2: Case-sensitive identifiers
    Value = 1;
    value = 0;
    VALUE = 0;
    if (Value === 1'b1 && value === 1'b0 && VALUE === 1'b0) begin
      $display("PASS: Test 2 - Case-sensitive identifiers (Value, value, VALUE are distinct)");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Case-sensitive identifiers");
      fail_count++;
    end

    // Test 3: Verify they are truly distinct
    Value = 1;
    value = 2;
    VALUE = 3;
    if (Value == 1 && value == 2 && VALUE == 3) begin
      $display("PASS: Test 3 - All three case variants hold different values");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Case variant confusion");
      fail_count++;
    end

    // Test 4: Long identifier
    this_is_a_very_long_identifier_name_for_testing_purposes = 1;
    if (this_is_a_very_long_identifier_name_for_testing_purposes === 1'b1) begin
      $display("PASS: Test 4 - Long identifier works");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Long identifier");
      fail_count++;
    end

    // Test 5: Identifiers with numbers
    var1 = 1;
    var2 = 0;
    data_8bit = 1;
    if (var1 == 1 && var2 == 0 && data_8bit == 1) begin
      $display("PASS: Test 5 - Identifiers with numbers");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Identifiers with numbers");
      fail_count++;
    end

    // Test 6: Reserved word check (using non-reserved variations)
    begin
      int begin_time;  // 'begin' is reserved but 'begin_time' is not
      int end_count;   // 'end' is reserved but 'end_count' is not
      begin_time = 100;
      end_count = 50;
      if (begin_time == 100 && end_count == 50) begin
        $display("PASS: Test 6 - Non-reserved identifier variations work");
        pass_count++;
      end else begin
        $display("FAIL: Test 6 - Non-reserved identifier variations");
        fail_count++;
      end
    end

    // Summary
    $display("");
    $display("=== Test Summary ===");
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", fail_count);

    if (fail_count == 0) begin
      $display("ALL TESTS PASSED");
    end else begin
      $display("SOME TESTS FAILED");
    end

    $finish;
  end
endmodule
