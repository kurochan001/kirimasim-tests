/*
:name: test_exists_method_2
:description: Test for exists() method implementation
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.3 7.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exists_method_2.expected
*/
// Test for exists() method implementation
// IEEE 1800-2023 §7.9.3: exists() is only valid for associative arrays
module test_exists_method_2;
    int failure_count = 0;

    // Associative array with int key
    int assoc_int[int];

    // Associative array with string key
    string assoc_str[string];

    // Associative array with wildcard index
    int assoc_wild[*];

    initial begin
        $display("=== IEEE 1800-2023 exists() Method Test ===");
        $display("Testing exists() on associative arrays only (§7.9.3)");

        // Test 1: Associative array with int key
        $display("\nTest 1: Associative array with int key");
        assoc_int[0] = 100;
        assoc_int[5] = 500;
        assoc_int[10] = 1000;

        // Should exist
        if (!assoc_int.exists(0)) begin
            $display("FAIL: assoc_int.exists(0) should return 1");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(0) = 1");
        end

        if (!assoc_int.exists(5)) begin
            $display("FAIL: assoc_int.exists(5) should return 1");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(5) = 1");
        end

        if (!assoc_int.exists(10)) begin
            $display("FAIL: assoc_int.exists(10) should return 1");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(10) = 1");
        end

        // Should not exist
        if (assoc_int.exists(1)) begin
            $display("FAIL: assoc_int.exists(1) should return 0");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(1) = 0");
        end

        if (assoc_int.exists(-1)) begin
            $display("FAIL: assoc_int.exists(-1) should return 0");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(-1) = 0");
        end

        // Test 2: Associative array with string key
        $display("\nTest 2: Associative array with string key");
        assoc_str["hello"] = "world";
        assoc_str["foo"] = "bar";

        // Should exist
        if (!assoc_str.exists("hello")) begin
            $display("FAIL: assoc_str.exists(\"hello\") should return 1");
            failure_count++;
        end else begin
            $display("PASS: assoc_str.exists(\"hello\") = 1");
        end

        if (!assoc_str.exists("foo")) begin
            $display("FAIL: assoc_str.exists(\"foo\") should return 1");
            failure_count++;
        end else begin
            $display("PASS: assoc_str.exists(\"foo\") = 1");
        end

        // Should not exist
        if (assoc_str.exists("baz")) begin
            $display("FAIL: assoc_str.exists(\"baz\") should return 0");
            failure_count++;
        end else begin
            $display("PASS: assoc_str.exists(\"baz\") = 0");
        end

        if (assoc_str.exists("")) begin
            $display("FAIL: assoc_str.exists(\"\") should return 0");
            failure_count++;
        end else begin
            $display("PASS: assoc_str.exists(\"\") = 0");
        end

        // Test 3: Delete and check exists
        $display("\nTest 3: Delete and check exists");
        assoc_int.delete(5);

        if (assoc_int.exists(5)) begin
            $display("FAIL: assoc_int.exists(5) should return 0 after delete");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(5) = 0 after delete");
        end

        // Other keys should still exist
        if (!assoc_int.exists(0)) begin
            $display("FAIL: assoc_int.exists(0) should still return 1");
            failure_count++;
        end else begin
            $display("PASS: assoc_int.exists(0) = 1 (unchanged)");
        end

        // Test 4: Empty associative array
        $display("\nTest 4: Empty associative array");
        assoc_wild.delete();  // Clear all

        if (assoc_wild.exists(0)) begin
            $display("FAIL: empty assoc_wild.exists(0) should return 0");
            failure_count++;
        end else begin
            $display("PASS: empty assoc_wild.exists(0) = 0");
        end

        // Add element and check
        assoc_wild[42] = 12345;
        if (!assoc_wild.exists(42)) begin
            $display("FAIL: assoc_wild.exists(42) should return 1 after assignment");
            failure_count++;
        end else begin
            $display("PASS: assoc_wild.exists(42) = 1 after assignment");
        end

        // Report results
        $display("\n=== Test Summary ===");
        if (failure_count == 0) begin
            $display("All exists() tests PASSED");
            $display("PASS");
        end else begin
            $display("FAIL: %0d test(s) failed", failure_count);
        end

        $finish;
    end
endmodule
