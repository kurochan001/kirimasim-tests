/*
:name: test_array_multidim_query
:description: Multi-dimensional array query functions test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 7.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_multidim_query.expected
*/
// IEEE 1800-2023 §20.7: array query functions. $dimensions counts every
// dimension, packed and unpacked, static or dynamic, and an integer element
// type counts as one packed dimension [n-1:0]. So $dimensions of an int
// dynamic array or queue is 2.
module test_array_multidim_query;

  // Test 1: unpacked array of 4 bytes (one packed and one unpacked dimension)
  logic [7:0] arr2d [4];  // 4 elements, each 8-bit

  // Test 2: Explicit bounds array [2:5][10:20]
  int arr_explicit [6][11];  // same as [0:5][0:10] (7.4.2)

  // Test 3: Dynamic array (1D)
  int dyn_arr[];

  // Test 4: Queue (1D)
  int queue_arr[$];

  initial begin
    int dim_count;
    int left_val, right_val, low_val, high_val;

    // Test $dimensions
    dim_count = $dimensions(arr2d);
    if (dim_count != 2) begin
      $fatal(1, "FAIL: $dimensions(arr2d) = %0d, expected 2", dim_count);
    end
    $display("PASS: $dimensions(arr2d) = %0d", dim_count);

    // Test $left, $right, $low, $high for first dimension
    left_val = $left(arr2d, 1);
    right_val = $right(arr2d, 1);
    low_val = $low(arr2d, 1);
    high_val = $high(arr2d, 1);
    $display("arr2d[1]: $left=%0d, $right=%0d, $low=%0d, $high=%0d",
             left_val, right_val, low_val, high_val);

    // Dynamic array tests
    dyn_arr = new[10];
    dim_count = $dimensions(dyn_arr);
    if (dim_count != 2) begin
      $fatal(1, "FAIL: $dimensions(dyn_arr) = %0d, expected 2", dim_count);
    end
    $display("PASS: $dimensions(dyn_arr) = %0d", dim_count);

    left_val = $left(dyn_arr);
    right_val = $right(dyn_arr);
    if (left_val != 0 || right_val != 9) begin
      $fatal(1, "FAIL: dyn_arr bounds: left=%0d, right=%0d, expected 0,9", left_val, right_val);
    end
    $display("PASS: dyn_arr bounds correct (0:9)");

    // Queue tests
    queue_arr = '{1, 2, 3, 4, 5};
    dim_count = $dimensions(queue_arr);
    if (dim_count != 2) begin
      $fatal(1, "FAIL: $dimensions(queue_arr) = %0d, expected 2", dim_count);
    end
    $display("PASS: $dimensions(queue_arr) = %0d", dim_count);

    left_val = $left(queue_arr);
    right_val = $right(queue_arr);
    low_val = $low(queue_arr);
    high_val = $high(queue_arr);
    if (low_val != 0 || high_val != 4) begin
      $fatal(1, "FAIL: queue_arr bounds: low=%0d, high=%0d, expected 0,4", low_val, high_val);
    end
    $display("PASS: queue_arr bounds correct (0:4)");

    // Test scalar (0 dimensions)
    begin
      logic scalar_val;
      dim_count = $dimensions(scalar_val);
      if (dim_count != 0) begin
        $fatal(1, "FAIL: $dimensions(scalar) = %0d, expected 0", dim_count);
      end
      $display("PASS: $dimensions(scalar) = 0");
    end

    // Test packed vector (1 packed dimension per IEEE 1800-2023 §6.11.1, the
    // simple bit vector definition, and §20.7's total-dimension rule)
    // $dimensions returns total packed + unpacked dimensions
    begin
      logic [31:0] packed_vec;
      dim_count = $dimensions(packed_vec);
      if (dim_count != 1) begin
        $fatal(1, "FAIL: $dimensions(packed_vec) = %0d, expected 1", dim_count);
      end
      $display("PASS: $dimensions(packed_vec) = 1");
    end

    $display("PASS: All multi-dimensional array query tests passed");
    $finish(0);
  end

endmodule
