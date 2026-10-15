/*
:name: test_class_methods_2
:description: Tests class instantiation, methods, constructors
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_methods_2.expected
*/
// IEEE 1800-2023 §8 Classes
// Tests class instantiation, methods, constructors

module test_class_methods;
    int pass_count = 0;
    int fail_count = 0;

    class Counter;
        int value;
        int increment_count;

        function new();
            value = 0;
            increment_count = 0;
        endfunction

        function void init(int v);
            value = v;
        endfunction

        function void increment();
            value++;
            increment_count++;
        endfunction

        function void decrement();
            value--;
        endfunction

        function int get_value();
            return value;
        endfunction

        function void add(int n);
            value += n;
        endfunction

        function void reset();
            value = 0;
            increment_count = 0;
        endfunction
    endclass

    class Point;
        int x, y;

        function new();
            x = 0;
            y = 0;
        endfunction

        function void set_pos(int px, int py);
            x = px;
            y = py;
        endfunction

        function int manhattan_distance();
            return (x >= 0 ? x : -x) + (y >= 0 ? y : -y);
        endfunction

        function void move(int dx, int dy);
            x += dx;
            y += dy;
        endfunction
    endclass

    Counter cnt;
    Point pt;

    initial begin
        // Test 1: Default constructor
        cnt = new();
        if (cnt.value == 0) begin
            $display("PASS: Default constructor");
            pass_count++;
        end else begin
            $display("FAIL: Default constructor - value=%0d", cnt.value);
            fail_count++;
        end

        // Test 2: Init method
        cnt = new();
        cnt.init(100);
        if (cnt.value == 100) begin
            $display("PASS: Init method");
            pass_count++;
        end else begin
            $display("FAIL: Init method - value=%0d", cnt.value);
            fail_count++;
        end

        // Test 3: Method calls
        cnt = new();
        cnt.increment();
        cnt.increment();
        cnt.increment();
        if (cnt.value == 3 && cnt.increment_count == 3) begin
            $display("PASS: Method calls - increment");
            pass_count++;
        end else begin
            $display("FAIL: Method calls - value=%0d, count=%0d",
                     cnt.value, cnt.increment_count);
            fail_count++;
        end

        // Test 4: Method with return value
        cnt = new();
        cnt.init(42);
        if (cnt.get_value() == 42) begin
            $display("PASS: Method with return value");
            pass_count++;
        end else begin
            $display("FAIL: get_value returned %0d", cnt.get_value());
            fail_count++;
        end

        // Test 5: Method with parameter
        cnt = new();
        cnt.init(10);
        cnt.add(5);
        if (cnt.value == 15) begin
            $display("PASS: Method with parameter");
            pass_count++;
        end else begin
            $display("FAIL: add method - value=%0d", cnt.value);
            fail_count++;
        end

        // Test 6: Point class with set_pos
        pt = new();
        pt.set_pos(3, 4);
        if (pt.x == 3 && pt.y == 4) begin
            $display("PASS: Point set_pos method");
            pass_count++;
        end else begin
            $display("FAIL: Point set_pos - x=%0d, y=%0d", pt.x, pt.y);
            fail_count++;
        end

        // Test 7: Manhattan distance
        pt = new();
        pt.set_pos(3, -4);
        if (pt.manhattan_distance() == 7) begin
            $display("PASS: Manhattan distance calculation");
            pass_count++;
        end else begin
            $display("FAIL: Manhattan distance - got %0d", pt.manhattan_distance());
            fail_count++;
        end

        // Test 8: Move method
        pt = new();
        pt.move(5, 10);
        if (pt.x == 5 && pt.y == 10) begin
            $display("PASS: Move method");
            pass_count++;
        end else begin
            $display("FAIL: Move - x=%0d, y=%0d", pt.x, pt.y);
            fail_count++;
        end

        $display("");
        $display("=== Class Methods Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
