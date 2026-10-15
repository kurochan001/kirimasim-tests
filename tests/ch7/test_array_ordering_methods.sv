/*
:name: test_array_ordering_methods
:description: Array manipulation methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_ordering_methods.expected
*/
// IEEE 1800-2023 Section 7.12 - Array manipulation methods
// Test: reverse, sort, rsort, shuffle

module test_array_ordering_methods;
  int data[] = '{50, 10, 30, 20, 40};
  int result[];

  initial begin
    // Test reverse() - reverses array order
    result = data;
    result.reverse();
    if (result.size() != 5) $fatal(1, "FAIL: reverse() size");
    if (result[0] != 40) $fatal(1, "FAIL: reverse()[0]");
    if (result[1] != 20) $fatal(1, "FAIL: reverse()[1]");
    if (result[2] != 30) $fatal(1, "FAIL: reverse()[2]");
    if (result[3] != 10) $fatal(1, "FAIL: reverse()[3]");
    if (result[4] != 50) $fatal(1, "FAIL: reverse()[4]");

    // Test sort() - ascending order
    result = data;
    result.sort();
    if (result.size() != 5) $fatal(1, "FAIL: sort() size");
    if (result[0] != 10) $fatal(1, "FAIL: sort()[0]");
    if (result[1] != 20) $fatal(1, "FAIL: sort()[1]");
    if (result[2] != 30) $fatal(1, "FAIL: sort()[2]");
    if (result[3] != 40) $fatal(1, "FAIL: sort()[3]");
    if (result[4] != 50) $fatal(1, "FAIL: sort()[4]");

    // Test rsort() - descending order
    result = data;
    result.rsort();
    if (result.size() != 5) $fatal(1, "FAIL: rsort() size");
    if (result[0] != 50) $fatal(1, "FAIL: rsort()[0]");
    if (result[1] != 40) $fatal(1, "FAIL: rsort()[1]");
    if (result[2] != 30) $fatal(1, "FAIL: rsort()[2]");
    if (result[3] != 20) $fatal(1, "FAIL: rsort()[3]");
    if (result[4] != 10) $fatal(1, "FAIL: rsort()[4]");

    // Test shuffle() - randomizes order
    result = data;
    result.shuffle();
    if (result.size() != 5) $fatal(1, "FAIL: shuffle() size");
    // Can't check exact order due to randomness, but check all elements present
    result.sort();
    if (result[0] != 10) $fatal(1, "FAIL: shuffle() missing 10");
    if (result[1] != 20) $fatal(1, "FAIL: shuffle() missing 20");
    if (result[2] != 30) $fatal(1, "FAIL: shuffle() missing 30");
    if (result[3] != 40) $fatal(1, "FAIL: shuffle() missing 40");
    if (result[4] != 50) $fatal(1, "FAIL: shuffle() missing 50");

    $display("PASS: Array ordering methods");
    $finish(0);
  end
endmodule
