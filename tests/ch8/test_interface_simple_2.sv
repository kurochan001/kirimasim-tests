/*
:name: test_interface_simple_2
:description: Simplified interface class test - IEEE 1800-2023 Ch.8.26
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_simple_2.expected
*/
// Simplified interface class test - IEEE 1800-2023 Ch.8.26

// Interface class with pure virtual methods only
interface class Shape;
    pure virtual function real getArea();
    pure virtual function string getName();
endclass

// Implementation class
class Circle implements Shape;
    real radius;

    function new(real r);
        radius = r;
    endfunction

    virtual function real getArea();
        return 3.14159 * radius * radius;
    endfunction

    virtual function string getName();
        return "Circle";
    endfunction
endclass

class Rectangle implements Shape;
    real width, height;

    function new(real w, real h);
        width = w;
        height = h;
    endfunction

    virtual function real getArea();
        return width * height;
    endfunction

    virtual function string getName();
        return "Rectangle";
    endfunction
endclass

// Test module
module test_interface_simple_2;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        Circle c;
        Rectangle r;
        Shape s;

        $display("=== Interface Class Test (IEEE 1800-2023 §8.26) ===");

        // Test 1: Circle via interface
        $display("\nTest 1: Circle via Shape interface");
        c = new(5.0);
        s = c;  // Upcast to interface

        if (s.getName() == "Circle") begin
            $display("PASS: getName() = %s", s.getName());
            pass_count++;
        end else begin
            $display("FAIL: getName() expected Circle, got %s", s.getName());
            fail_count++;
        end

        // Check area (5^2 * pi = 78.54)
        if (s.getArea() > 78.0 && s.getArea() < 79.0) begin
            $display("PASS: getArea() = %f", s.getArea());
            pass_count++;
        end else begin
            $display("FAIL: getArea() expected ~78.54, got %f", s.getArea());
            fail_count++;
        end

        // Test 2: Rectangle via interface
        $display("\nTest 2: Rectangle via Shape interface");
        r = new(4.0, 6.0);
        s = r;  // Upcast to interface

        if (s.getName() == "Rectangle") begin
            $display("PASS: getName() = %s", s.getName());
            pass_count++;
        end else begin
            $display("FAIL: getName() expected Rectangle, got %s", s.getName());
            fail_count++;
        end

        // Check area (4 * 6 = 24)
        if (s.getArea() == 24.0) begin
            $display("PASS: getArea() = %f", s.getArea());
            pass_count++;
        end else begin
            $display("FAIL: getArea() expected 24.0, got %f", s.getArea());
            fail_count++;
        end

        // Summary
        $display("\n=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end

        $finish;
    end
endmodule
