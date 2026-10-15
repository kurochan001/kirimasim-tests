/*
:name: test_func_basic_2
:description: Basic function declaration test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_basic_2.expected
*/
// Basic function declaration test
module test_func_basic;

  // Simple function returning int
  function int add(int a, int b);
    return a + b;
  endfunction

  // Function with logic return type
  function logic [7:0] get_byte(logic [31:0] word, int index);
    case (index)
      0: return word[7:0];
      1: return word[15:8];
      2: return word[23:16];
      3: return word[31:24];
      default: return 8'h00;
    endcase
  endfunction

  // Function with no arguments
  function int get_constant();
    return 42;
  endfunction

  // Function with single argument
  function int double_val(int x);
    return x * 2;
  endfunction

  // Function with local variables
  function int sum_range(int start_val, int end_val);
    int total;
    total = 0;
    for (int i = start_val; i <= end_val; i++) begin
      total = total + i;
    end
    return total;
  endfunction

  initial begin
    int result;
    logic [31:0] test_word;
    int pass_count;

    pass_count = 0;

    // Test 1: Simple addition function
    result = add(3, 5);
    if (result == 8) begin
      $display("Test 1 PASS: add(3, 5) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: add(3, 5) = %0d, expected 8", result);
    end

    // Test 2: Byte extraction function
    test_word = 32'hDEADBEEF;
    if (get_byte(test_word, 0) == 8'hEF &&
        get_byte(test_word, 1) == 8'hBE &&
        get_byte(test_word, 2) == 8'hAD &&
        get_byte(test_word, 3) == 8'hDE) begin
      $display("Test 2 PASS: get_byte extracts correctly");
      pass_count++;
    end else begin
      $display("Test 2 FAIL: get_byte extraction error");
    end

    // Test 3: No argument function
    result = get_constant();
    if (result == 42) begin
      $display("Test 3 PASS: get_constant() = %0d", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: get_constant() = %0d, expected 42", result);
    end

    // Test 4: Single argument function
    result = double_val(7);
    if (result == 14) begin
      $display("Test 4 PASS: double_val(7) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: double_val(7) = %0d, expected 14", result);
    end

    // Test 5: Function with local variables and loop
    result = sum_range(1, 5);
    if (result == 15) begin
      $display("Test 5 PASS: sum_range(1, 5) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: sum_range(1, 5) = %0d, expected 15", result);
    end

    if (pass_count == 5)
      $display("PASS: All basic function tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
