/*
:name: test_ref_arg
:description: Test ref arguments (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_arg.expected
*/
// Test ref arguments (IEEE 1800-2023 Section 13.5.2)

module test_ref_arg;
  int pass_count;
  int val;
  int arr [];

  function automatic void increment(ref int x);
    x++;
  endfunction

  function automatic void swap(ref int a, ref int b);
    int tmp;
    tmp = a;
    a = b;
    b = tmp;
  endfunction

  function automatic void double_all(ref int a[]);
    foreach (a[i]) a[i] *= 2;
  endfunction

  initial begin
    int x, y;
    pass_count = 0;

    // Test 1: Simple ref
    val = 10;
    increment(val);
    if (val == 11) pass_count++;

    // Test 2: Multiple increments
    increment(val);
    increment(val);
    if (val == 13) pass_count++;

    // Test 3: Swap
    x = 5;
    y = 10;
    swap(x, y);
    if (x == 10 && y == 5) pass_count++;

    // Test 4: Array ref
    arr = new[3];
    arr = '{1, 2, 3};
    double_all(arr);
    if (arr[0] == 2 && arr[1] == 4 && arr[2] == 6) pass_count++;

    $display("Ref arg tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Ref arg tests");
    end else begin
      $display("FAIL: Some ref tests failed");
    end
  end
endmodule
