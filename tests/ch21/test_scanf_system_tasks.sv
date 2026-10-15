/*
:name: test_scanf_system_tasks
:description: Test for $sscanf system task
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scanf_system_tasks.expected
*/
// Test for $sscanf system task
// IEEE 1800-2023 §21.3.4
module test_scanf_system_tasks;

  int test_count = 0;
  int pass_count = 0;

  // Variables for scanning
  int int_val;
  real real_val;
  string str_val;
  logic [31:0] hex_val;
  logic [31:0] bin_val;
  logic [31:0] oct_val;

  initial begin
    // Test basic integer scanning
    test_count++;
    if ($sscanf("123", "%d", int_val) == 1 && int_val == 123) begin
      $display("PASS: $sscanf integer = 123");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf integer expected 123, got %0d", int_val);
    end

    // Test negative integer
    test_count++;
    if ($sscanf("-456", "%d", int_val) == 1 && int_val == -456) begin
      $display("PASS: $sscanf negative integer = -456");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf negative integer expected -456, got %0d", int_val);
    end

    // Test hexadecimal scanning
    test_count++;
    if ($sscanf("CAFE", "%h", hex_val) == 1 && hex_val == 32'hCAFE) begin
      $display("PASS: $sscanf hex = 0xCAFE");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf hex expected 0xCAFE, got 0x%h", hex_val);
    end

    // Test binary scanning
    test_count++;
    if ($sscanf("10101010", "%b", bin_val) == 1 && bin_val == 32'b10101010) begin
      $display("PASS: $sscanf binary = 0b10101010");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf binary expected 0b10101010, got 0b%b", bin_val);
    end

    // Test octal scanning
    test_count++;
    if ($sscanf("755", "%o", oct_val) == 1 && oct_val == 32'o755) begin
      $display("PASS: $sscanf octal = 0o755");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf octal expected 0o755, got 0o%o", oct_val);
    end

    // Test real scanning
    test_count++;
    if ($sscanf("3.14159", "%f", real_val) == 1 && real_val > 3.14 && real_val < 3.15) begin
      $display("PASS: $sscanf real = 3.14159");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf real expected 3.14159, got %f", real_val);
    end

    // Test string scanning
    test_count++;
    if ($sscanf("hello", "%s", str_val) == 1 && str_val == "hello") begin
      $display("PASS: $sscanf string = hello");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf string expected hello, got %s", str_val);
    end

    // Test multiple values
    test_count++;
    if ($sscanf("42 3.14", "%d %f", int_val, real_val) == 2 && int_val == 42 && real_val > 3.1 && real_val < 3.2) begin
      $display("PASS: $sscanf multiple = 42, 3.14");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf multiple expected 42, 3.14, got %0d, %f", int_val, real_val);
    end

    // Test with leading whitespace
    test_count++;
    if ($sscanf("   999", "%d", int_val) == 1 && int_val == 999) begin
      $display("PASS: $sscanf with whitespace = 999");
      pass_count++;
    end else begin
      $display("FAIL: $sscanf with whitespace expected 999, got %0d", int_val);
    end

    // Summary
    $display("\n=== Test Summary ===");
    $display("Tests: %0d, Passed: %0d, Failed: %0d", test_count, pass_count, test_count - pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All scanf system tasks tests passed");
    end else begin
      $display("FAIL: Some scanf system tasks tests failed");
    end
    $finish;
  end

endmodule
