/*
:name: test_assoc_array_ops_2
:description: Test: Associative array exists, first, last, next, prev, delete operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9 7.9.3 7.9.4 7.9.5 7.9.6
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_ops_2.expected
*/
// Test: Associative array exists, first, last, next, prev, delete operations
module test_assoc_array_ops_2;
    int aa[string];
    string key;
    int value;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Setup associative array
        aa["apple"] = 1;
        aa["banana"] = 2;
        aa["cherry"] = 3;
        aa["date"] = 4;

        // Test 1: exists
        if (aa.exists("banana") && !aa.exists("grape")) begin
            $display("PASS: exists works correctly");
            pass_count++;
        end else begin
            $display("FAIL: exists - banana should exist, grape should not");
            fail_count++;
        end

        // Test 2: first
        if (aa.first(key)) begin
            if (key == "apple") begin
                $display("PASS: first returns 'apple'");
                pass_count++;
            end else begin
                $display("FAIL: first - expected 'apple', got '%s'", key);
                fail_count++;
            end
        end else begin
            $display("FAIL: first returned 0 on non-empty array");
            fail_count++;
        end

        // Test 3: last
        if (aa.last(key)) begin
            if (key == "date") begin
                $display("PASS: last returns 'date'");
                pass_count++;
            end else begin
                $display("FAIL: last - expected 'date', got '%s'", key);
                fail_count++;
            end
        end else begin
            $display("FAIL: last returned 0 on non-empty array");
            fail_count++;
        end

        // Test 4: next
        key = "banana";
        if (aa.next(key)) begin
            if (key == "cherry") begin
                $display("PASS: next after 'banana' returns 'cherry'");
                pass_count++;
            end else begin
                $display("FAIL: next - expected 'cherry', got '%s'", key);
                fail_count++;
            end
        end else begin
            $display("FAIL: next returned 0 for 'banana'");
            fail_count++;
        end

        // Test 5: prev
        key = "cherry";
        if (aa.prev(key)) begin
            if (key == "banana") begin
                $display("PASS: prev before 'cherry' returns 'banana'");
                pass_count++;
            end else begin
                $display("FAIL: prev - expected 'banana', got '%s'", key);
                fail_count++;
            end
        end else begin
            $display("FAIL: prev returned 0 for 'cherry'");
            fail_count++;
        end

        // Test 6: delete single key
        aa.delete("banana");
        if (!aa.exists("banana") && aa.exists("apple")) begin
            $display("PASS: delete single key works");
            pass_count++;
        end else begin
            $display("FAIL: delete single key - banana should be deleted");
            fail_count++;
        end

        // Summary
        $display("Associative array ops test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All associative array tests passed");
        $finish;
    end
endmodule
