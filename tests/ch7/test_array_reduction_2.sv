/*
:name: test_array_reduction_2
:description: Test array reduction methods (IEEE 1800-2023 Section 7.12)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_2.expected
*/
// Test array reduction methods (IEEE 1800-2023 Section 7.12)

module test_array_reduction_2;
  int arr[5];
  logic [7:0] bits[4];
  int result;
  logic [7:0] bit_result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Initialize arrays
    arr = '{10, 20, 30, 40, 50};
    bits = '{8'hFF, 8'h0F, 8'hF0, 8'hAA};

    // Test 1: sum
    result = arr.sum();
    if (result == 150) pass_count++;

    // Test 2: sum with expression
    result = arr.sum(x) with (x * 2);
    if (result == 300) pass_count++;

    // Test 3: product
    result = arr.product();
    if (result == 12000000) pass_count++;

    // Test 4: and reduction
    bit_result = bits.and();
    if (bit_result == 8'h00) pass_count++;

    // Test 5: or reduction
    bit_result = bits.or();
    if (bit_result == 8'hFF) pass_count++;

    // Test 6: xor reduction
    begin
      static logic [7:0] xor_arr[3] = '{8'hFF, 8'hFF, 8'h00};
      bit_result = xor_arr.xor();
      if (bit_result == 8'h00) pass_count++;
    end

    // Test 7: size using $size
    if ($size(arr) == 5) pass_count++;

    $display("Array reduction tests: %0d/7 passed", pass_count);
    if (pass_count == 7) begin
      $display("PASS: Array reduction tests");
    end else begin
      $display("FAIL: Some array reduction tests failed");
    end
  end
endmodule
