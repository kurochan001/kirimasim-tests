/*
:name: test_function_early_return
:description: Multiple Return Statements
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_early_return.expected
*/
// IEEE 1800-2023 Sections 13.4.1 and 12.8: Multiple Return Statements
// Tests early return behavior in functions

module test_function_early_return;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Multiple return paths
    function automatic int find_first_positive(int arr[]);
        foreach (arr[i]) begin
            if (arr[i] > 0) return arr[i];
        end
        return -1;  // not found
    endfunction

    // Test 2: Return in nested conditionals
    function automatic int grade_to_points(string grade);
        if (grade == "A") return 4;
        else if (grade == "B") return 3;
        else if (grade == "C") return 2;
        else if (grade == "D") return 1;
        else return 0;
    endfunction

    // Test 3: Return in case statement
    function automatic string day_name(int day);
        case (day)
            1: return "Monday";
            2: return "Tuesday";
            3: return "Wednesday";
            4: return "Thursday";
            5: return "Friday";
            6: return "Saturday";
            7: return "Sunday";
            default: return "Invalid";
        endcase
    endfunction

    // Test 4: Return in loop with break-like behavior
    function automatic int binary_search(int arr[], int target);
        int left = 0;
        int right = arr.size() - 1;
        while (left <= right) begin
            int mid = (left + right) / 2;
            if (arr[mid] == target) return mid;
            else if (arr[mid] < target) left = mid + 1;
            else right = mid - 1;
        end
        return -1;
    endfunction

    // Test 5: Void function with early return
    int side_effect_val;
    function automatic void early_void_return(int n);
        if (n < 0) return;  // early exit
        side_effect_val = n * 2;
    endfunction

    // Test 6: Return expression evaluation
    function automatic int return_expr(int a, int b);
        return (a > b) ? a : b;
    endfunction

    // Test 7: Return in try-like pattern
    function automatic int safe_divide(int a, int b);
        if (b == 0) return 0;  // guard
        return a / b;
    endfunction

    initial begin
        static int arr1[] = '{-1, -2, 3, -4, 5};
        static int arr2[] = '{1, 3, 5, 7, 9, 11, 13};

        // Test 1: Find first positive
        if (find_first_positive(arr1) == 3) pass_count++;
        else begin fail_count++; $display("FAIL: find first positive"); end

        // Test 2: Grade to points
        if (grade_to_points("A") == 4 && grade_to_points("C") == 2 && grade_to_points("F") == 0)
            pass_count++;
        else begin fail_count++; $display("FAIL: grade to points"); end

        // Test 3: Day name
        if (day_name(1) == "Monday" && day_name(7) == "Sunday" && day_name(0) == "Invalid")
            pass_count++;
        else begin fail_count++; $display("FAIL: day name"); end

        // Test 4: Binary search
        if (binary_search(arr2, 7) == 3) pass_count++;
        else begin fail_count++; $display("FAIL: binary search found"); end
        if (binary_search(arr2, 8) == -1) pass_count++;
        else begin fail_count++; $display("FAIL: binary search not found"); end

        // Test 5: Void early return
        side_effect_val = 0;
        early_void_return(-5);
        if (side_effect_val == 0) pass_count++;  // should not change
        else begin fail_count++; $display("FAIL: void early return"); end
        early_void_return(10);
        if (side_effect_val == 20) pass_count++;
        else begin fail_count++; $display("FAIL: void normal return"); end

        // Test 6: Return expression
        if (return_expr(5, 3) == 5 && return_expr(2, 8) == 8) pass_count++;
        else begin fail_count++; $display("FAIL: return expr"); end

        // Test 7: Safe divide
        if (safe_divide(10, 2) == 5 && safe_divide(10, 0) == 0) pass_count++;
        else begin fail_count++; $display("FAIL: safe divide"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/9)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
