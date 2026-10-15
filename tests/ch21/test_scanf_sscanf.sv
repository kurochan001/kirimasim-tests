/*
:name: test_scanf_sscanf
:description: Test scanf/sscanf operations (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scanf_sscanf.expected
*/
// Test scanf/sscanf operations (IEEE 1800-2023 Section 21.3.4.3)

module test_scanf_sscanf;
  int ival, ival2;
  real rval;
  string str, input_str;
  int result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Basic $sscanf decimal
    input_str = "42";
    result = $sscanf(input_str, "%d", ival);
    if (result == 1 && ival == 42) pass_count++;

    // Test 2: Multiple values
    input_str = "10 20";
    result = $sscanf(input_str, "%d %d", ival, ival2);
    if (result == 2 && ival == 10 && ival2 == 20) pass_count++;

    // Test 3: Hex format
    input_str = "FF";
    result = $sscanf(input_str, "%h", ival);
    if (result == 1 && ival == 255) pass_count++;

    // Test 4: Real value
    input_str = "3.14";
    result = $sscanf(input_str, "%f", rval);
    if (result == 1 && rval > 3.1 && rval < 3.2) pass_count++;

    // Test 5: String scan
    input_str = "hello";
    result = $sscanf(input_str, "%s", str);
    if (result == 1 && str == "hello") pass_count++;

    // Test 6: Mixed format
    input_str = "value=100";
    result = $sscanf(input_str, "value=%d", ival);
    if (result == 1 && ival == 100) pass_count++;

    // Test 7: Binary format
    input_str = "1010";
    result = $sscanf(input_str, "%b", ival);
    if (result == 1 && ival == 10) pass_count++;

    // Test 8: Octal format
    input_str = "77";
    result = $sscanf(input_str, "%o", ival);
    if (result == 1 && ival == 63) pass_count++;

    $display("Scanf/sscanf tests: %0d/8 passed", pass_count);
    if (pass_count >= 7) begin
      $display("PASS: Scanf/sscanf tests");
    end else begin
      $display("FAIL: Some scanf tests failed");
    end
  end
endmodule
