/*
:name: test_class_new
:description: Class Constructor Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 13.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_new.expected
*/
// IEEE 1800-2023 Section 8 - Class Constructor Tests
module test_class_new;
    int pass_count = 0;
    int fail_count = 0;

    class Point;
        int x, y;

        function new(int x_val = 0, int y_val = 0);
            x = x_val;
            y = y_val;
        endfunction
    endclass

    class Counter;
        int count;

        function new();
            count = 0;
        endfunction

        function void increment();
            count++;
        endfunction
    endclass

    initial begin
        Point p1, p2, p3;
        Counter c1;

        $display("=== IEEE 1800-2023 Class Constructor Tests ===");

        // Test 1: Default constructor
        $display("Test 1: Default new");
        p1 = new();
        if (p1.x == 0 && p1.y == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: x=%0d y=%0d", p1.x, p1.y); fail_count++; end

        // Test 2: With args
        $display("Test 2: With args");
        p2 = new(10, 20);
        if (p2.x == 10 && p2.y == 20) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: x=%0d y=%0d", p2.x, p2.y); fail_count++; end

        // Test 3: Partial args
        $display("Test 3: Partial args");
        p3 = new(5);
        if (p3.x == 5 && p3.y == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: x=%0d y=%0d", p3.x, p3.y); fail_count++; end

        // Test 4: Multiple objects
        $display("Test 4: Multiple objects");
        p1 = new(1, 1);
        p2 = new(2, 2);
        if (p1.x == 1 && p2.x == 2) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Counter new
        $display("Test 5: Counter new");
        c1 = new();
        if (c1.count == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", c1.count); fail_count++; end

        // Test 6: Increment after new
        $display("Test 6: Increment");
        c1.increment();
        c1.increment();
        if (c1.count == 2) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", c1.count); fail_count++; end

        // Test 7: Reassign
        $display("Test 7: Reassign");
        p1 = new(100, 200);
        if (p1.x == 100 && p1.y == 200) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Negative args
        $display("Test 8: Negative args");
        p1 = new(-5, -10);
        if (p1.x == -5 && p1.y == -10) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
