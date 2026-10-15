/*
:name: test_cast_dynamic_array
:description: $cast to array elements
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 7.5 7.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_dynamic_array.expected
*/
// IEEE 1800-2023 Section 6.24.2 - $cast to array elements
// Tests: Dynamic array, queue, and complex array base support

module test_cast_dynamic_array;

    // Base class for testing
    class Base;
        int value;
        function new(int v = 0);
            value = v;
        endfunction
    endclass

    // Container class with array members
    class Container;
        Base items[];     // Dynamic array of base class
        Base queue_items[$];  // Queue of base class

        function new();
            Base b;
            items = new[3];
            for (int i = 0; i < 3; i++) begin
                b = new(i * 10);
                items[i] = b;
            end
        endfunction
    endclass

    // Test variables
    Base arr[];
    Base queue_items[$];
    Container container;
    Base b1, b2, b3;
    int result;
    int tests_passed = 0;
    int tests_failed = 0;
    int i;

    initial begin
        // Create base instances with different values
        b1 = new(100);
        b2 = new(200);
        b3 = new(300);

        // Initialize dynamic array
        arr = new[4];
        for (i = 0; i < 4; i++) begin
            arr[i] = new(i);
        end

        // Initialize queue
        begin
            Base q1, q2, q3;
            q1 = new(10);
            q2 = new(20);
            q3 = new(30);
            queue_items.push_back(q1);
            queue_items.push_back(q2);
            queue_items.push_back(q3);
        end

        // Initialize container
        container = new();

        // Test 1: $cast to dynamic array element (basic)
        $display("Test 1: arr[0].value before=%0d", arr[0].value);
        result = $cast(arr[0], b1);
        $display("Test 1: arr[0].value after=%0d, result=%0d", arr[0].value, result);
        if (result == 1 && arr[0].value == 100) begin
            $display("PASS: Test 1 - $cast to dynamic array element");
            tests_passed++;
        end else begin
            $display("FAIL: Test 1 - $cast to dynamic array element (result=%0d, value=%0d)",
                     result, arr[0].value);
            tests_failed++;
        end

        // Test 2: $cast to dynamic array element with index expression
        result = $cast(arr[1 + 1], b2);
        if (result == 1 && arr[2].value == 200) begin
            $display("PASS: Test 2 - $cast to dynamic array element with index expression");
            tests_passed++;
        end else begin
            $display("FAIL: Test 2 - $cast to dynamic array element with index expr (result=%0d, value=%0d)",
                     result, arr[2].value);
            tests_failed++;
        end

        // Test 3: $cast to queue element
        $display("Test 3: queue_items[1].value before=%0d", queue_items[1].value);
        result = $cast(queue_items[1], b3);
        $display("Test 3: queue_items[1].value after=%0d, result=%0d", queue_items[1].value, result);
        if (result == 1 && queue_items[1].value == 300) begin
            $display("PASS: Test 3 - $cast to queue element");
            tests_passed++;
        end else begin
            $display("FAIL: Test 3 - $cast to queue element (result=%0d, value=%0d)",
                     result, queue_items[1].value);
            tests_failed++;
        end

        // Test 4: $cast to class member array element (complex base)
        $display("Test 4: container.items[1].value before=%0d", container.items[1].value);
        result = $cast(container.items[1], b2);
        $display("Test 4: container.items[1].value after=%0d, result=%0d", container.items[1].value, result);
        if (result == 1 && container.items[1].value == 200) begin
            $display("PASS: Test 4 - $cast to class member array element");
            tests_passed++;
        end else begin
            $display("FAIL: Test 4 - $cast to class member array (result=%0d, value=%0d)",
                     result, container.items[1].value);
            tests_failed++;
        end

        // Summary
        $display("");
        $display("=== Test Summary ===");
        $display("Tests passed: %0d", tests_passed);
        $display("Tests failed: %0d", tests_failed);

        if (tests_failed == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end

        $finish;
    end

endmodule
