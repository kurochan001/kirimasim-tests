/*
:name: test_assoc_array_methods
:description: Test for IEEE 1800-2023 §7.8: Associative array methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_methods.expected
*/
// Test for IEEE 1800-2023 §7.8: Associative array methods

module test_assoc_array_methods;
    int aa[string];
    int aa_int[int];
    int result;
    string str_key;
    int int_key;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== Associative Array Methods Test ===");

        // Initialize associative array with string keys
        aa["apple"] = 10;
        aa["banana"] = 20;
        aa["cherry"] = 30;

        // Test num()
        result = aa.num();
        if (result == 3) begin
            $display("PASS: aa.num() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: aa.num() expected 3, got %0d", result);
            fail_count++;
        end

        // Test size() - same as num()
        result = aa.size();
        if (result == 3) begin
            $display("PASS: aa.size() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: aa.size() expected 3, got %0d", result);
            fail_count++;
        end

        // Test exists()
        result = aa.exists("apple");
        if (result == 1) begin
            $display("PASS: aa.exists(\"apple\") = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: aa.exists(\"apple\") expected 1, got %0d", result);
            fail_count++;
        end

        result = aa.exists("grape");
        if (result == 0) begin
            $display("PASS: aa.exists(\"grape\") = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: aa.exists(\"grape\") expected 0, got %0d", result);
            fail_count++;
        end

        // Test first()
        if (aa.first(str_key)) begin
            $display("PASS: aa.first() = \"%s\"", str_key);
            pass_count++;
        end else begin
            $display("FAIL: aa.first() returned 0");
            fail_count++;
        end

        // Test last()
        if (aa.last(str_key)) begin
            $display("PASS: aa.last() = \"%s\"", str_key);
            pass_count++;
        end else begin
            $display("FAIL: aa.last() returned 0");
            fail_count++;
        end

        // Test next()
        str_key = "apple";
        if (aa.next(str_key)) begin
            $display("PASS: aa.next(\"apple\") = \"%s\"", str_key);
            pass_count++;
        end else begin
            $display("FAIL: aa.next(\"apple\") returned 0");
            fail_count++;
        end

        // Test prev()
        str_key = "cherry";
        if (aa.prev(str_key)) begin
            $display("PASS: aa.prev(\"cherry\") = \"%s\"", str_key);
            pass_count++;
        end else begin
            $display("FAIL: aa.prev(\"cherry\") returned 0");
            fail_count++;
        end

        // Test delete(key)
        aa.delete("banana");
        if (aa.num() == 2 && !aa.exists("banana")) begin
            $display("PASS: delete(\"banana\") - num = %0d", aa.num());
            pass_count++;
        end else begin
            $display("FAIL: delete(\"banana\") incorrect");
            fail_count++;
        end

        // Test delete() - clear all
        aa.delete();
        if (aa.num() == 0) begin
            $display("PASS: delete() cleared all - num = %0d", aa.num());
            pass_count++;
        end else begin
            $display("FAIL: delete() expected 0, got %0d", aa.num());
            fail_count++;
        end

        // Test with integer keys
        aa_int[100] = 1000;
        aa_int[200] = 2000;
        aa_int[300] = 3000;

        if (aa_int.num() == 3) begin
            $display("PASS: aa_int.num() = %0d", aa_int.num());
            pass_count++;
        end else begin
            $display("FAIL: aa_int.num() expected 3, got %0d", aa_int.num());
            fail_count++;
        end

        result = aa_int.exists(200);
        if (result == 1) begin
            $display("PASS: aa_int.exists(200) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: aa_int.exists(200) expected 1, got %0d", result);
            fail_count++;
        end

        if (aa_int.first(int_key)) begin
            $display("PASS: aa_int.first() = %0d", int_key);
            pass_count++;
        end else begin
            $display("FAIL: aa_int.first()");
            fail_count++;
        end

        // Summary
        $display("\n=== Associative Array Methods Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
