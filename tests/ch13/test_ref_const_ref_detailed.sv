/*
:name: test_ref_const_ref_detailed
:description: Reference Arguments (ref/const ref)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_const_ref_detailed.expected
*/
// IEEE 1800-2023 Section 13.5.2: Reference Arguments (ref/const ref)
// Tests detailed behavior of ref and const ref function/task arguments

module test_ref_const_ref_detailed;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: const ref for read-only access to array
    function automatic int sum_array_const_ref(const ref int arr[]);
        int sum = 0;
        foreach (arr[i]) sum += arr[i];
        return sum;
    endfunction

    // Test 2: ref argument to modify array
    task automatic modify_array_ref(ref int arr[], input int multiplier);
        foreach (arr[i]) arr[i] *= multiplier;
    endtask

    // Test 3: ref with class object
    class Data;
        int value;
        function new(int v); value = v; endfunction
    endclass

    task automatic modify_object_ref(ref Data obj);
        obj.value *= 2;
    endtask

    // Test 4: ref with queue
    function automatic int queue_pop_ref(ref int q[$]);
        if (q.size() > 0)
            return q.pop_front();
        return -1;
    endfunction

    // Test 5: const ref with struct
    typedef struct {
        int x, y;
    } point_t;

    function automatic int point_sum_const_ref(const ref point_t p);
        return p.x + p.y;
    endfunction

    // Test 6: ref with associative array
    task automatic clear_assoc_ref(ref int aa[string]);
        aa.delete();
    endtask

    initial begin
        static int arr[] = '{1, 2, 3, 4, 5};
        Data d;
        static int q[$] = '{10, 20, 30};
        static point_t pt = '{100, 200};
        int aa[string];

        // Test 1: const ref read
        if (sum_array_const_ref(arr) == 15) pass_count++;
        else begin fail_count++; $display("FAIL: const ref sum"); end

        // Test 2: ref array modify
        modify_array_ref(arr, 2);
        if (arr[0] == 2 && arr[4] == 10) pass_count++;
        else begin fail_count++; $display("FAIL: ref array modify"); end

        // Test 3: ref object modify
        d = new(10);
        modify_object_ref(d);
        if (d.value == 20) pass_count++;
        else begin fail_count++; $display("FAIL: ref object"); end

        // Test 4: ref queue pop
        if (queue_pop_ref(q) == 10 && q.size() == 2) pass_count++;
        else begin fail_count++; $display("FAIL: ref queue"); end

        // Test 5: const ref struct
        if (point_sum_const_ref(pt) == 300) pass_count++;
        else begin fail_count++; $display("FAIL: const ref struct"); end

        // Test 6: ref associative array
        aa["a"] = 1; aa["b"] = 2;
        clear_assoc_ref(aa);
        if (aa.size() == 0) pass_count++;
        else begin fail_count++; $display("FAIL: ref assoc array"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/6)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
