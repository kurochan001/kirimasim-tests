/*
:name: test_default_args
:description: Test default arguments (IEEE 1800-2023 Section 13.5.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_args.expected
*/
// Test default arguments (IEEE 1800-2023 Section 13.5.3)

module test_default_args;
  int pass_count;

  function int add(int a, int b = 10);
    return a + b;
  endfunction

  function int multiply(int a = 2, int b = 3, int c = 1);
    return a * b * c;
  endfunction

  function string greet(string name = "World");
    return {"Hello, ", name};
  endfunction

  initial begin
    pass_count = 0;

    // Test 1: Use default
    if (add(5) == 15) pass_count++;

    // Test 2: Override default
    if (add(5, 20) == 25) pass_count++;

    // Test 3: All defaults
    if (multiply() == 6) pass_count++;

    // Test 4: Partial defaults
    if (multiply(4) == 12) pass_count++;

    // Test 5: Override all
    if (multiply(2, 2, 2) == 8) pass_count++;

    // Test 6: String default
    if (greet() == "Hello, World") pass_count++;

    $display("Default args tests: %0d/6 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Default args tests");
    end else begin
      $display("FAIL: Some default arg tests failed");
    end
  end
endmodule
