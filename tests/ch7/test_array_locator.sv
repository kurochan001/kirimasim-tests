/*
:name: test_array_locator
:description: Array locator methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_locator.expected
*/
// IEEE 1800-2023 Section 7.12.1: Array locator methods
module test_array_locator;
    int arr[] = '{5, 2, 8, 1, 9, 3};
    int queue[$];
    int result[];
    int idx[];

    int fails = 0;


    initial begin
        // find() - returns queue of matching elements
        queue = arr.find(x) with (x > 5);
        if (queue.size() == 2 && queue[0] == 8 && queue[1] == 9)
            $display("PASS: find(x > 5)");
        else
            begin fails++; $display("FAIL: find size = %0d", queue.size()); end

        // find_index()
        idx = arr.find_index(x) with (x == 8);
        if (idx.size() == 1 && idx[0] == 2)
            $display("PASS: find_index(x == 8) = 2");
        else
            begin fails++; $display("FAIL: find_index size = %0d", idx.size()); end

        // find_first()
        queue = arr.find_first(x) with (x > 3);
        if (queue.size() == 1 && queue[0] == 5)
            $display("PASS: find_first(x > 3) = 5");
        else
            begin fails++; $display("FAIL: find_first"); end

        // find_last()
        queue = arr.find_last(x) with (x < 5);
        if (queue.size() == 1 && queue[0] == 3)
            $display("PASS: find_last(x < 5) = 3");
        else
            begin fails++; $display("FAIL: find_last"); end

        // min()
        queue = arr.min();
        if (queue.size() == 1 && queue[0] == 1)
            $display("PASS: min() = 1");
        else
            begin fails++; $display("FAIL: min"); end

        // max()
        queue = arr.max();
        if (queue.size() == 1 && queue[0] == 9)
            $display("PASS: max() = 9");
        else
            begin fails++; $display("FAIL: max"); end

        if (fails == 0) $display("TEST PASSED: array locator tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
