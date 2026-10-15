/*
:name: test_abstract_class_basic
:description: Abstract class with pure virtual methods implemented by two derived classes
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.21 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abstract_class_basic.expected
*/
// Abstract class with pure virtual methods, implemented by two derived classes

`timescale 1ns/1ps

// Abstract base class with pure virtual methods
virtual class AbstractShape;
    // Abstract method that must be implemented by derived classes
    pure virtual function real getArea();
    pure virtual function real getPerimeter();

    // Concrete method that can be inherited
    virtual function void display();
        $display("This is a shape");
    endfunction

    // Another concrete method
    function void printInfo();
        $display("Area: %f, Perimeter: %f", getArea(), getPerimeter());
    endfunction
endclass

// Concrete derived class that implements all abstract methods
class Rectangle extends AbstractShape;
    real width, height;

    function new(real w, real h);
        width = w;
        height = h;
    endfunction

    // Implementation of abstract method
    virtual function real getArea();
        return width * height;
    endfunction

    // Implementation of abstract method
    virtual function real getPerimeter();
        return 2 * (width + height);
    endfunction

    // Override concrete method
    virtual function void display();
        $display("Rectangle: width=%f, height=%f", width, height);
    endfunction
endclass

// Another concrete implementation
class Circle extends AbstractShape;
    real radius;

    function new(real r);
        radius = r;
    endfunction

    virtual function real getArea();
        return 3.14159 * radius * radius;
    endfunction

    virtual function real getPerimeter();
        return 2 * 3.14159 * radius;
    endfunction

    virtual function void display();
        $display("Circle: radius=%f", radius);
    endfunction
endclass

module test_abstract_class_basic;
    Rectangle rect;
    Circle circle;
    AbstractShape shape; // Can declare handle but cannot instantiate

    initial begin
        $display("=== Abstract Class Basic Test ===");

        // Test 1: Create concrete instances (should work)
        $display("\n--- Test 1: Creating concrete instances ---");
        rect = new(5.0, 3.0);
        circle = new(4.0);

        $display("Rectangle created successfully");
        $display("Circle created successfully");

        // Test 2: Use polymorphism
        $display("\n--- Test 2: Polymorphic usage ---");
        shape = rect;
        shape.display();
        shape.printInfo();

        shape = circle;
        shape.display();
        shape.printInfo();

        // Test 3: Method resolution test
        $display("\n--- Test 3: Method resolution test ---");
        $display("Rectangle area: %f", rect.getArea());
        $display("Rectangle perimeter: %f", rect.getPerimeter());
        $display("Circle area: %f", circle.getArea());
        $display("Circle perimeter: %f", circle.getPerimeter());

        $display("\n=== Test completed successfully ===");
        $finish;
    end
endmodule
