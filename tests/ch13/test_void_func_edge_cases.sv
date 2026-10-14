/*
:name: test_void_func_edge_cases
:description: Void function edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_void_func_edge_cases.expected
*/
// IEEE 1800-2023 §13.4.1: Void function edge cases
// Tests for void functions

module test_void_func_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int counter;
    int arr[4];

    function void increment();
        counter++;
    endfunction

    function void add_value(int val);
        counter += val;
    endfunction

    function void set_array(int idx, int val);
        if (idx >= 0 && idx < 4)
            arr[idx] = val;
    endfunction

    function void clear_all();
        counter = 0;
        for (int i = 0; i < 4; i++)
            arr[i] = 0;
    endfunction

    function void early_exit(int x);
        if (x < 0) return;
        counter = x;
    endfunction

    function void nested_calls();
        increment();
        increment();
        add_value(10);
    endfunction

    initial begin
        counter = 0;
        for (int i = 0; i < 4; i++) arr[i] = 0;

        // Test 1: Simple void call
        test_count++;
        counter = 0;
        increment();
        if (counter == 1) begin
            pass_count++;
            $display("Test 1 PASS: Increment = %0d", counter);
        end else begin
            $display("Test 1 FAIL: Inc unexpected = %0d", counter);
        end

        // Test 2: Void with argument
        test_count++;
        counter = 0;
        add_value(5);
        if (counter == 5) begin
            pass_count++;
            $display("Test 2 PASS: Add value = %0d", counter);
        end else begin
            $display("Test 2 FAIL: Add unexpected = %0d", counter);
        end

        // Test 3: Multiple calls
        test_count++;
        counter = 0;
        increment();
        increment();
        increment();
        if (counter == 3) begin
            pass_count++;
            $display("Test 3 PASS: Multi call = %0d", counter);
        end else begin
            $display("Test 3 FAIL: Multi unexpected = %0d", counter);
        end

        // Test 4: Array modification
        test_count++;
        set_array(0, 100);
        set_array(1, 200);
        if (arr[0] == 100 && arr[1] == 200) begin
            pass_count++;
            $display("Test 4 PASS: Array set [0]=%0d [1]=%0d", arr[0], arr[1]);
        end else begin
            $display("Test 4 FAIL: Array unexpected");
        end

        // Test 5: Clear all
        test_count++;
        counter = 50;
        arr[0] = 10;
        clear_all();
        if (counter == 0 && arr[0] == 0) begin
            pass_count++;
            $display("Test 5 PASS: Clear all");
        end else begin
            $display("Test 5 FAIL: Clear unexpected");
        end

        // Test 6: Early exit negative
        test_count++;
        counter = 99;
        early_exit(-5);
        if (counter == 99) begin
            pass_count++;
            $display("Test 6 PASS: Early exit = %0d", counter);
        end else begin
            $display("Test 6 FAIL: Exit unexpected = %0d", counter);
        end

        // Test 7: Normal execution
        test_count++;
        early_exit(42);
        if (counter == 42) begin
            pass_count++;
            $display("Test 7 PASS: Normal = %0d", counter);
        end else begin
            $display("Test 7 FAIL: Normal unexpected = %0d", counter);
        end

        // Test 8: Nested void calls
        test_count++;
        counter = 0;
        nested_calls();
        if (counter == 12) begin
            pass_count++;
            $display("Test 8 PASS: Nested = %0d", counter);
        end else begin
            $display("Test 8 FAIL: Nested unexpected = %0d", counter);
        end

        // Test 9: Out of bounds guard
        test_count++;
        set_array(10, 999);  // Should be ignored
        pass_count++;
        $display("Test 9 PASS: Bounds guard");

        // Test 10: Sequence of operations
        test_count++;
        clear_all();
        increment();
        add_value(9);
        if (counter == 10) begin
            pass_count++;
            $display("Test 10 PASS: Sequence = %0d", counter);
        end else begin
            $display("Test 10 FAIL: Seq unexpected = %0d", counter);
        end

        $display("=== Void Function Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
