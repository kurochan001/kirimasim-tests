/*
:name: test_array_method
:description: Array ordering, locator and unique methods on a fixed-size int array
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method.expected
*/
`timescale 1ns/1ps

module test_array_method;
    int arr[10];
    int result[];

    int fails = 0;


    initial begin
        // Initialize
        foreach (arr[i]) arr[i] = 10 - i;

        // Sort
        arr.sort();
        if (arr[0] != 1) begin fails++; $display("FAIL: sort min"); end
        if (arr[9] != 10) begin fails++; $display("FAIL: sort max"); end

        // Reverse sort
        arr.rsort();
        if (arr[0] != 10) begin fails++; $display("FAIL: rsort max"); end
        if (arr[9] != 1) begin fails++; $display("FAIL: rsort min"); end

        // Shuffle
        arr.shuffle();
        // shuffle only reorders: sorting again gives the same elements
        arr.sort();
        if (arr[0] != 1 || arr[9] != 10 || arr.sum() != 55) begin fails++; $display("FAIL: shuffle"); end

        // Reverse
        arr = '{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        arr.reverse();
        if (arr[0] != 10) begin fails++; $display("FAIL: reverse"); end

        // Find methods
        arr = '{5, 10, 15, 20, 25, 30, 35, 40, 45, 50};

        result = arr.find(x) with (x > 30);
        if (result.size() != 4) begin fails++; $display("FAIL: find count"); end

        result = arr.find_first(x) with (x > 20);
        if (result[0] != 25) begin fails++; $display("FAIL: find_first"); end

        result = arr.find_last(x) with (x < 40);
        if (result[0] != 35) begin fails++; $display("FAIL: find_last"); end

        // Min/max
        result = arr.min();
        if (result[0] != 5) begin fails++; $display("FAIL: min"); end

        result = arr.max();
        if (result[0] != 50) begin fails++; $display("FAIL: max"); end

        // Unique
        begin
            static int dup[] = '{1, 2, 2, 3, 3, 3, 4};
            result = dup.unique();
            if (result.size() != 4) begin fails++; $display("FAIL: unique"); end
        end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
