/*
:name: test_min_max_func
:description: Functions returning the minimum and maximum through the conditional operator
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_min_max_func.expected
*/
// Functions returning the minimum and maximum through the conditional operator

module test_min_max_func;
  int a, b, result;
  int pass_count;

  function int get_min(int x, int y);
    return (x < y) ? x : y;
  endfunction

  function int get_max(int x, int y);
    return (x > y) ? x : y;
  endfunction

  initial begin
    pass_count = 0;

    // Test 1: Min with first smaller
    a = 5;
    b = 10;
    result = get_min(a, b);
    if (result == 5) pass_count++;

    // Test 2: Min with second smaller
    result = get_min(b, a);
    if (result == 5) pass_count++;

    // Test 3: Max with first larger
    result = get_max(b, a);
    if (result == 10) pass_count++;

    // Test 4: Max with second larger
    result = get_max(a, b);
    if (result == 10) pass_count++;

    // Test 5: Equal values
    result = get_min(7, 7);
    if (result == 7) pass_count++;

    // Test 6: Negative values
    result = get_min(-5, -10);
    if (result == -10) pass_count++;

    // Test 7: Mixed signs
    result = get_max(-5, 5);
    if (result == 5) pass_count++;

    $display("Min/max tests: %0d/7 passed", pass_count);
    if (pass_count == 7) begin
      $display("PASS: Min/max tests");
    end else begin
      $display("FAIL: Some min/max tests failed");
    end
  end
endmodule
