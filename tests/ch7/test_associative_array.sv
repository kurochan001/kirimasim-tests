/*
:name: test_associative_array
:description: Associative Arrays (§7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_array.expected
*/
// IEEE 1800-2023 Associative Arrays (§7.8)
// Tests associative array operations

module test_associative_array;
    initial begin
        int aa_int[string];
        string aa_str[int];
        static int pass_count = 0;
        static int fail_count = 0;
        string key;
        int idx;

        // Test 1: Initial num() is 0
        if (aa_int.num() == 0) begin
            $display("PASS: Initial num() is 0");
            pass_count++;
        end else begin
            $display("FAIL: Initial num() should be 0");
            fail_count++;
        end

        // Test 2: Insert and retrieve
        aa_int["apple"] = 10;
        aa_int["banana"] = 20;
        aa_int["cherry"] = 30;

        if (aa_int["apple"] == 10 && aa_int["banana"] == 20) begin
            $display("PASS: Insert and retrieve works");
            pass_count++;
        end else begin
            $display("FAIL: Insert/retrieve failed");
            fail_count++;
        end

        // Test 3: num() after inserts
        if (aa_int.num() == 3) begin
            $display("PASS: num() is 3 after 3 inserts");
            pass_count++;
        end else begin
            $display("FAIL: num() should be 3, got %0d", aa_int.num());
            fail_count++;
        end

        // Test 4: exists()
        if (aa_int.exists("apple") && !aa_int.exists("grape")) begin
            $display("PASS: exists() works correctly");
            pass_count++;
        end else begin
            $display("FAIL: exists() not working");
            fail_count++;
        end

        // Test 5: delete by key
        aa_int.delete("banana");
        if (aa_int.num() == 2 && !aa_int.exists("banana")) begin
            $display("PASS: delete by key works");
            pass_count++;
        end else begin
            $display("FAIL: delete by key failed");
            fail_count++;
        end

        // Test 6: first() and next()
        if (aa_int.first(key)) begin
            $display("PASS: first() returns key '%s'", key);
            pass_count++;
        end else begin
            $display("FAIL: first() should succeed");
            fail_count++;
        end

        // Test 7: Integer key associative array
        aa_str[100] = "hundred";
        aa_str[200] = "two hundred";

        if (aa_str[100] == "hundred" && aa_str.num() == 2) begin
            $display("PASS: Integer key AA works");
            pass_count++;
        end else begin
            $display("FAIL: Integer key AA failed");
            fail_count++;
        end

        // Test 8: delete all
        aa_int.delete();
        if (aa_int.num() == 0) begin
            $display("PASS: delete() clears all");
            pass_count++;
        end else begin
            $display("FAIL: delete() should clear all");
            fail_count++;
        end

        $display("");
        $display("=== Associative Array Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
