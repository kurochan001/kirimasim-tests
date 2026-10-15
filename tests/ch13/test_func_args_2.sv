/*
:name: test_func_args_2
:description: Function arguments test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_args_2.expected
*/
// Function arguments test
module test_func_args_2;

  // Function with input arguments (default direction)
  function int add_inputs(int a, int b);
    return a + b;
  endfunction

  // Function with explicit input direction
  function int multiply(input int x, input int y);
    return x * y;
  endfunction

  // Function with output argument
  function int compute_with_output(input int a, output int doubled);
    doubled = a * 2;
    return a + 1;
  endfunction

  // Function with inout argument
  function int modify_inout(inout int value);
    int original;
    original = value;
    value = value * 3;
    return original;
  endfunction

  // Function with multiple argument types
  function logic [15:0] pack_bytes(input byte high, input byte low);
    return {high, low};
  endfunction

  // Function with array argument
  function int sum_array(input int arr[4]);
    int total;
    total = 0;
    for (int i = 0; i < 4; i++) begin
      total = total + arr[i];
    end
    return total;
  endfunction

  initial begin
    int result, out_val, inout_val;
    logic [15:0] packed_val;
    int test_arr[4];
    int pass_count;

    pass_count = 0;

    // Test 1: Basic input arguments
    result = add_inputs(10, 20);
    if (result == 30) begin
      $display("Test 1 PASS: add_inputs(10, 20) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: add_inputs(10, 20) = %0d, expected 30", result);
    end

    // Test 2: Explicit input direction
    result = multiply(6, 7);
    if (result == 42) begin
      $display("Test 2 PASS: multiply(6, 7) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: multiply(6, 7) = %0d, expected 42", result);
    end

    // Test 3: Output argument
    result = compute_with_output(5, out_val);
    if (result == 6 && out_val == 10) begin
      $display("Test 3 PASS: compute_with_output(5) returned %0d, output = %0d", result, out_val);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: result = %0d (expected 6), output = %0d (expected 10)", result, out_val);
    end

    // Test 4: Inout argument
    inout_val = 4;
    result = modify_inout(inout_val);
    if (result == 4 && inout_val == 12) begin
      $display("Test 4 PASS: modify_inout returned %0d, inout_val = %0d", result, inout_val);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: returned %0d (expected 4), inout_val = %0d (expected 12)", result, inout_val);
    end

    // Test 5: Pack bytes function
    packed_val = pack_bytes(8'hAB, 8'hCD);
    if (packed_val == 16'hABCD) begin
      $display("Test 5 PASS: pack_bytes(0xAB, 0xCD) = 0x%04h", packed_val);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: pack_bytes(0xAB, 0xCD) = 0x%04h, expected 0xABCD", packed_val);
    end

    if (pass_count == 5)
      $display("PASS: All function arguments tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
