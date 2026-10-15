/*
:name: test_sv_assoc_array
:description: Test: Associative array: int map[string], exists(), first(), next(), delete(), num()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sv_assoc_array.expected
*/
// Test: Associative array: int map[string], exists(), first(), next(), delete(), num()
module test_sv_assoc_array;

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    int map[string];
    string key;

    // Check 1: num() on empty
    if (map.num() == 0) begin pass_cnt++; $display("PASS: initial num == 0"); end
    else begin fail_cnt++; $display("FAIL: initial num = %0d", map.num()); end

    // Check 2: insert and read
    map["apple"] = 10;
    map["banana"] = 20;
    map["cherry"] = 30;
    if (map["banana"] == 20) begin pass_cnt++; $display("PASS: map[banana] == 20"); end
    else begin fail_cnt++; $display("FAIL: map[banana] = %0d", map["banana"]); end

    // Check 3: num() after inserts
    if (map.num() == 3) begin pass_cnt++; $display("PASS: num == 3"); end
    else begin fail_cnt++; $display("FAIL: num = %0d", map.num()); end

    // Check 4: exists() positive
    if (map.exists("cherry")) begin pass_cnt++; $display("PASS: exists(cherry)"); end
    else begin fail_cnt++; $display("FAIL: cherry not found"); end

    // Check 5: exists() negative
    if (!map.exists("grape")) begin pass_cnt++; $display("PASS: !exists(grape)"); end
    else begin fail_cnt++; $display("FAIL: grape unexpectedly found"); end

    // Check 6: first() returns smallest key (lexicographic)
    if (map.first(key) && key == "apple") begin pass_cnt++; $display("PASS: first == apple"); end
    else begin fail_cnt++; $display("FAIL: first key = %s", key); end

    // Check 7: next() traversal
    if (map.next(key) && key == "banana") begin pass_cnt++; $display("PASS: next == banana"); end
    else begin fail_cnt++; $display("FAIL: next key = %s", key); end

    // Check 8: delete single entry
    map.delete("banana");
    if (!map.exists("banana") && map.num() == 2) begin pass_cnt++; $display("PASS: delete banana"); end
    else begin fail_cnt++; $display("FAIL: after delete banana, num=%0d", map.num()); end

    // Check 9: delete all
    map.delete();
    if (map.num() == 0) begin pass_cnt++; $display("PASS: delete all, num == 0"); end
    else begin fail_cnt++; $display("FAIL: after delete all, num = %0d", map.num()); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
