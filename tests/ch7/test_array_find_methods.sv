/*
:name: test_array_find_methods
:description: Array manipulation methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_find_methods.expected
*/
// IEEE 1800-2023 Section 7.12 - Array manipulation methods
// Test: find, find_first, find_last, find_index

module test_array_find_methods;
  int data[] = '{10, 20, 30, 20, 40, 20, 50};
  int result[$];
  int indices[$];

  initial begin
    // Test find() - returns all matching elements
    result = data.find(x) with (x == 20);
    if (result.size() != 3) $fatal(1, "FAIL: find() size");
    if (result[0] != 20) $fatal(1, "FAIL: find()[0]");
    if (result[1] != 20) $fatal(1, "FAIL: find()[1]");
    if (result[2] != 20) $fatal(1, "FAIL: find()[2]");

    // Test find_first() - returns first matching element
    result = data.find_first(x) with (x > 25);
    if (result.size() != 1) $fatal(1, "FAIL: find_first() size");
    if (result[0] != 30) $fatal(1, "FAIL: find_first() value");

    // Test find_last() - returns last matching element
    result = data.find_last(x) with (x == 20);
    if (result.size() != 1) $fatal(1, "FAIL: find_last() size");
    if (result[0] != 20) $fatal(1, "FAIL: find_last() value");

    // Test find_index() - returns all matching indices
    indices = data.find_index(x) with (x == 20);
    // Locator methods traverse the array in an unspecified order (7.12.1)
    indices.sort();
    if (indices.size() != 3) $fatal(1, "FAIL: find_index() size");
    if (indices[0] != 1) $fatal(1, "FAIL: find_index()[0] - index 1");
    if (indices[1] != 3) $fatal(1, "FAIL: find_index()[1] - index 3");
    if (indices[2] != 5) $fatal(1, "FAIL: find_index()[2] - index 5");

    // Test find_first_index()
    indices = data.find_first_index(x) with (x >= 40);
    if (indices.size() != 1) $fatal(1, "FAIL: find_first_index() size");
    if (indices[0] != 4) $fatal(1, "FAIL: find_first_index() - should be index 4");

    // Test find_last_index()
    indices = data.find_last_index(x) with (x < 30);
    if (indices.size() != 1) $fatal(1, "FAIL: find_last_index() size");
    if (indices[0] != 5) $fatal(1, "FAIL: find_last_index() - should be index 5");

    // Test with no matches
    result = data.find(x) with (x == 100);
    if (result.size() != 0) $fatal(1, "FAIL: find() no matches should return empty queue");

    $display("PASS: Array find methods");
    $finish(0);
  end
endmodule
