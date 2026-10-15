/*
:name: test_assoc_array
:description: Associative arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9.1 7.9.2 7.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array.expected
*/
// IEEE 1800-2023 Section 7.8: Associative arrays
module test_assoc_array;
    int aa[string];
    int aa_int[int];
    string key;
    int value;

    int fails = 0;


    initial begin
        // Insert elements
        aa["apple"] = 10;
        aa["banana"] = 20;
        aa["cherry"] = 30;

        // num()
        if (aa.num() == 3)
            $display("PASS: aa.num() = 3");
        else
            begin fails++; $display("FAIL: aa.num() = %0d", aa.num()); end

        // exists()
        if (aa.exists("banana"))
            $display("PASS: exists('banana')");
        else
            begin fails++; $display("FAIL: exists check"); end

        if (!aa.exists("grape"))
            $display("PASS: !exists('grape')");
        else
            begin fails++; $display("FAIL: !exists check"); end

        // Access
        value = aa["apple"];
        if (value == 10)
            $display("PASS: aa['apple'] = 10");
        else
            begin fails++; $display("FAIL: access = %0d", value); end

        // delete()
        aa.delete("banana");
        if (aa.num() == 2)
            $display("PASS: delete reduced size");
        else
            begin fails++; $display("FAIL: delete, num = %0d", aa.num()); end

        // Integer key
        aa_int[100] = 1;
        aa_int[200] = 2;
        if (aa_int[100] == 1)
            $display("PASS: int key access");
        else
            begin fails++; $display("FAIL: int key = %0d", aa_int[100]); end

        if (fails == 0) $display("TEST PASSED: associative array tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
