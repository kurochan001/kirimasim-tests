/*
:name: test_output_ref_combination
:description: Output and Ref Argument Combination
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_output_ref_combination.expected
*/
// IEEE 1800-2023 Section 13.5.2: Output and Ref Argument Combination
// Tests combination of output, inout, and ref arguments

module test_output_ref_combination;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Multiple output arguments
    task automatic swap(input int a, input int b, output int out_a, output int out_b);
        out_a = b;
        out_b = a;
    endtask

    // Test 2: inout argument
    task automatic increment_inout(inout int val);
        val = val + 1;
    endtask

    // Test 3: Mixed input/output/inout
    task automatic process_mixed(input int in_val, inout int io_val, output int out_val);
        out_val = in_val + io_val;
        io_val = io_val * 2;
    endtask

    // Test 4: ref with output combination
    task automatic array_stats(ref int arr[], output int sum, output int count);
        sum = 0;
        count = arr.size();
        foreach (arr[i]) sum += arr[i];
    endtask

    // Test 5: inout with array
    task automatic double_array_inout(inout int arr[]);
        foreach (arr[i]) arr[i] *= 2;
    endtask

    // Test 6: Multiple ref arguments
    task automatic swap_ref(ref int a, ref int b);
        int temp = a;
        a = b;
        b = temp;
    endtask

    // Test 7: Function with output (via return + ref)
    function automatic int compute_with_side_effect(input int a, ref int accumulator);
        accumulator += a;
        return a * 2;
    endfunction

    // Test 8: Const ref + output
    function automatic int sum_and_count(const ref int arr[], output int count);
        int sum = 0;
        count = arr.size();
        foreach (arr[i]) sum += arr[i];
        return sum;
    endfunction

    initial begin
        int a, b, out_a, out_b;
        int io_val, out_val;
        static int arr[] = '{1, 2, 3, 4, 5};
        int sum, count;
        int accum;
        int result;

        // Test 1: Swap with output
        a = 10; b = 20;
        swap(a, b, out_a, out_b);
        if (out_a == 20 && out_b == 10) pass_count++;
        else begin fail_count++; $display("FAIL: swap output"); end

        // Test 2: inout increment
        io_val = 5;
        increment_inout(io_val);
        if (io_val == 6) pass_count++;
        else begin fail_count++; $display("FAIL: inout increment"); end

        // Test 3: Mixed arguments
        io_val = 10;
        process_mixed(5, io_val, out_val);
        if (out_val == 15 && io_val == 20) pass_count++;
        else begin fail_count++; $display("FAIL: mixed args"); end

        // Test 4: ref + output
        arr = '{1, 2, 3, 4, 5};
        array_stats(arr, sum, count);
        if (sum == 15 && count == 5) pass_count++;
        else begin fail_count++; $display("FAIL: ref + output"); end

        // Test 5: inout array
        arr = '{1, 2, 3};
        double_array_inout(arr);
        if (arr[0] == 2 && arr[1] == 4 && arr[2] == 6) pass_count++;
        else begin fail_count++; $display("FAIL: inout array"); end

        // Test 6: swap with ref
        a = 100; b = 200;
        swap_ref(a, b);
        if (a == 200 && b == 100) pass_count++;
        else begin fail_count++; $display("FAIL: swap ref"); end

        // Test 7: Function with ref side effect
        accum = 0;
        result = compute_with_side_effect(10, accum);
        if (result == 20 && accum == 10) pass_count++;
        else begin fail_count++; $display("FAIL: func ref side effect"); end
        result = compute_with_side_effect(5, accum);
        if (result == 10 && accum == 15) pass_count++;
        else begin fail_count++; $display("FAIL: func ref accumulate"); end

        // Test 8: const ref + output
        arr = '{10, 20, 30};
        sum = sum_and_count(arr, count);
        if (sum == 60 && count == 3) pass_count++;
        else begin fail_count++; $display("FAIL: const ref + output"); end

        if (fail_count == 0 && pass_count == 9)
            $display("TEST PASSED (%0d/9)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
