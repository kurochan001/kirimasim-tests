/*
:name: test_class_basic_edge_cases
:description: Class basic edge cases
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.6 8.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_basic_edge_cases.expected
*/
// IEEE 1800-2023 §8: Class basic edge cases
// Tests for class declaration and instantiation

class Counter;
    int value;
    
    function new(int init = 0);
        value = init;
    endfunction
    
    function void increment();
        value++;
    endfunction
    
    function int get();
        return value;
    endfunction
endclass

class Point;
    int x, y;
    
    function new(int px = 0, int py = 0);
        x = px;
        y = py;
    endfunction
endclass

module test_class_basic_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        Counter c1, c2;
        Point p1;

        // Test 1: New with default
        test_count++;
        c1 = new();
        if (c1.value == 0) begin
            pass_count++;
            $display("Test 1 PASS: Default new = %0d", c1.value);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %0d", c1.value);
        end

        // Test 2: New with argument
        test_count++;
        c2 = new(10);
        if (c2.value == 10) begin
            pass_count++;
            $display("Test 2 PASS: Init new = %0d", c2.value);
        end else begin
            $display("Test 2 FAIL: Init unexpected = %0d", c2.value);
        end

        // Test 3: Method call
        test_count++;
        c1.increment();
        if (c1.get() == 1) begin
            pass_count++;
            $display("Test 3 PASS: Method = %0d", c1.get());
        end else begin
            $display("Test 3 FAIL: Method unexpected = %0d", c1.get());
        end

        // Test 4: Independent instances
        test_count++;
        if (c1.value != c2.value) begin
            pass_count++;
            $display("Test 4 PASS: Independent c1=%0d c2=%0d", c1.value, c2.value);
        end else begin
            $display("Test 4 FAIL: Independent unexpected");
        end

        // Test 5: Multiple method calls
        test_count++;
        for (int i = 0; i < 5; i++) c1.increment();
        if (c1.get() == 6) begin
            pass_count++;
            $display("Test 5 PASS: Multi call = %0d", c1.get());
        end else begin
            $display("Test 5 FAIL: Multi unexpected = %0d", c1.get());
        end

        // Test 6: Point class
        test_count++;
        p1 = new(3, 4);
        if (p1.x == 3 && p1.y == 4) begin
            pass_count++;
            $display("Test 6 PASS: Point x=%0d y=%0d", p1.x, p1.y);
        end else begin
            $display("Test 6 FAIL: Point unexpected");
        end

        // Test 7: Null handle
        test_count++;
        begin
            Counter c3;
            if (c3 == null) begin
                pass_count++;
                $display("Test 7 PASS: Null handle");
            end else begin
                $display("Test 7 FAIL: Null unexpected");
            end
        end

        // Test 8: Reassignment
        test_count++;
        c1 = new(100);
        if (c1.value == 100) begin
            pass_count++;
            $display("Test 8 PASS: Reassign = %0d", c1.value);
        end else begin
            $display("Test 8 FAIL: Reassign unexpected = %0d", c1.value);
        end

        // Test 9: Direct property access
        test_count++;
        c1.value = 50;
        if (c1.get() == 50) begin
            pass_count++;
            $display("Test 9 PASS: Direct = %0d", c1.get());
        end else begin
            $display("Test 9 FAIL: Direct unexpected = %0d", c1.get());
        end

        // Test 10: Point default
        test_count++;
        p1 = new();
        if (p1.x == 0 && p1.y == 0) begin
            pass_count++;
            $display("Test 10 PASS: Point default");
        end else begin
            $display("Test 10 FAIL: Default unexpected");
        end

        $display("=== Class Basic Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
