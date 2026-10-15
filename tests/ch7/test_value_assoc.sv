/*
:name: test_value_assoc
:description: Test for associative array value operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_assoc.expected
*/
// Test for associative array value operations
// IEEE 1800-2023 §7.8: Associative arrays
module test_value_assoc;
    int fails = 0;

    initial begin
        int aa[string];
        int ia[int];
        string keys[$];
        int val;

        // String key operations
        aa["one"] = 1;
        aa["two"] = 2;
        aa["three"] = 3;

        if (aa["one"] != 1) begin fails++; $display("FAIL: String key read"); end
        if (aa.size() != 3) begin fails++; $display("FAIL: Size"); end

        // Exists check
        if (!aa.exists("two")) begin fails++; $display("FAIL: exists true"); end
        if (aa.exists("four")) begin fails++; $display("FAIL: exists false"); end

        // Delete
        aa.delete("two");
        if (aa.exists("two")) begin fails++; $display("FAIL: delete"); end

        // Integer key
        ia[100] = 10;
        ia[200] = 20;
        ia[50] = 5;

        // first and last
        if (ia.first(val)) begin
            if (val != 50) begin fails++; $display("FAIL: first %0d", val); end
        end else begin
            fails++; $display("FAIL: first() returned 0");
        end

        if (ia.last(val)) begin
            if (val != 200) begin fails++; $display("FAIL: last %0d", val); end
        end else begin
            fails++; $display("FAIL: last() returned 0");
        end

        if (fails == 0) $display("PASS: Associative array operations");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
