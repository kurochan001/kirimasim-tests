/*
:name: test_lrm_class_inheritance_8
:description: Class inheritance and polymorphism edge cases
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.15 8.20 8.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lrm_class_inheritance_8.expected
*/
// IEEE 1800-2023 §8.6-8.13: Class Inheritance and Polymorphism Edge Cases
// Tests virtual methods, super calls, abstract classes, and polymorphism

module test_lrm_class_inheritance_8;
    int pass_count = 0;
    int fail_count = 0;

    // §8.6: Base class with virtual method
    class Animal;
        string name;
        int age;

        function new(string n = "unknown", int a = 0);
            name = n;
            age = a;
        endfunction

        // §8.20: Virtual method for polymorphism
        virtual function string speak();
            return "...";
        endfunction

        virtual function int get_legs();
            return 0;
        endfunction

        function string describe();
            return $sformatf("%s is %0d years old", name, age);
        endfunction
    endclass

    // §8.13: Derived class overriding virtual methods
    class Dog extends Animal;
        string breed;

        function new(string n, int a, string b = "mixed");
            super.new(n, a);  // §8.15: super.new call
            breed = b;
        endfunction

        virtual function string speak();
            return "Woof!";
        endfunction

        virtual function int get_legs();
            return 4;
        endfunction

        function string get_breed();
            return breed;
        endfunction
    endclass

    // Another derived class
    class Bird extends Animal;
        bit can_fly;

        function new(string n, int a, bit fly = 1);
            super.new(n, a);
            can_fly = fly;
        endfunction

        virtual function string speak();
            return "Tweet!";
        endfunction

        virtual function int get_legs();
            return 2;
        endfunction
    endclass

    // §8.21: Multi-level inheritance
    class Puppy extends Dog;
        function new(string n);
            super.new(n, 0, "puppy");
        endfunction

        virtual function string speak();
            return "Yip!";
        endfunction
    endclass

    // §8.18: Abstract class (pure virtual methods simulated)
    virtual class Shape;
        pure virtual function real area();
        pure virtual function real perimeter();

        virtual function string type_name();
            return "Shape";
        endfunction
    endclass

    class Circle extends Shape;
        real radius;

        function new(real r);
            radius = r;
        endfunction

        virtual function real area();
            return 3.14159 * radius * radius;
        endfunction

        virtual function real perimeter();
            return 2.0 * 3.14159 * radius;
        endfunction

        virtual function string type_name();
            return "Circle";
        endfunction
    endclass

    class Rectangle extends Shape;
        real width, height;

        function new(real w, real h);
            width = w;
            height = h;
        endfunction

        virtual function real area();
            return width * height;
        endfunction

        virtual function real perimeter();
            return 2.0 * (width + height);
        endfunction

        virtual function string type_name();
            return "Rectangle";
        endfunction
    endclass

    // §8.9: Class with static members
    class Counter;
        static int count = 0;
        int id;

        function new();
            count++;
            id = count;
        endfunction

        static function int get_count();
            return count;
        endfunction

        static function void reset();
            count = 0;
        endfunction
    endclass

    // §8.26: Parameterized class
    class Container #(type T = int, int SIZE = 10);
        T data[SIZE];

        function void set(int idx, T val);
            if (idx >= 0 && idx < SIZE)
                data[idx] = val;
        endfunction

        function T get(int idx);
            if (idx >= 0 && idx < SIZE)
                return data[idx];
            else begin
                T default_val;
                return default_val;
            end
        endfunction
    endclass

    initial begin
        Animal a;
        Dog d;
        Bird b;
        Puppy p;
        Shape s;
        Circle c;
        Rectangle r;
        Counter c1, c2, c3;
        Container #(int, 5) int_container;
        Container #(string, 3) str_container;

        $display("=== IEEE 1800-2023 §8 Class Inheritance Tests ===");

        // Test 1: Basic inheritance
        $display("Test 1: Basic class instantiation and inheritance");
        d = new("Rex", 5, "German Shepherd");
        if (d.name == "Rex" && d.age == 5 && d.breed == "German Shepherd") begin
            pass_count++;
            $display("  PASS: Dog instantiation with super.new");
        end else begin
            fail_count++;
            $display("  FAIL: Dog instantiation");
        end

        // Test 2: Virtual method override
        $display("Test 2: Virtual method override");
        if (d.speak() == "Woof!" && d.get_legs() == 4) begin
            pass_count++;
            $display("  PASS: Dog virtual methods");
        end else begin
            fail_count++;
            $display("  FAIL: Dog virtual methods");
        end

        // Test 3: Polymorphism - base class handle to derived
        $display("Test 3: Polymorphism with base class handle");
        a = d;  // Assign derived to base handle
        if (a.speak() == "Woof!" && a.get_legs() == 4) begin
            pass_count++;
            $display("  PASS: Polymorphic method call");
        end else begin
            fail_count++;
            $display("  FAIL: Polymorphic method call (got '%s', legs=%0d)", a.speak(), a.get_legs());
        end

        // Test 4: Different derived class
        $display("Test 4: Bird class");
        b = new("Tweety", 2, 1);
        a = b;
        if (a.speak() == "Tweet!" && a.get_legs() == 2) begin
            pass_count++;
            $display("  PASS: Bird polymorphism");
        end else begin
            fail_count++;
            $display("  FAIL: Bird polymorphism");
        end

        // Test 5: Multi-level inheritance
        $display("Test 5: Multi-level inheritance (Puppy extends Dog)");
        p = new("Spot");
        if (p.speak() == "Yip!" && p.get_legs() == 4 && p.age == 0) begin
            pass_count++;
            $display("  PASS: Puppy multi-level inheritance");
        end else begin
            fail_count++;
            $display("  FAIL: Puppy multi-level inheritance");
        end

        // Test 6: Abstract class with pure virtual
        $display("Test 6: Abstract class implementation");
        c = new(5.0);
        s = c;
        if (s.type_name() == "Circle") begin
            pass_count++;
            $display("  PASS: Abstract class polymorphism");
        end else begin
            fail_count++;
            $display("  FAIL: Abstract class polymorphism");
        end

        // Test 7: Area calculation (virtual method)
        $display("Test 7: Virtual area calculation");
        r = new(4.0, 3.0);
        if (r.area() == 12.0 && r.perimeter() == 14.0) begin
            pass_count++;
            $display("  PASS: Rectangle area=%0f, perimeter=%0f", r.area(), r.perimeter());
        end else begin
            fail_count++;
            $display("  FAIL: Rectangle calculations");
        end

        // Test 8: Static class members
        $display("Test 8: Static class members");
        Counter::reset();
        c1 = new();
        c2 = new();
        c3 = new();
        if (Counter::get_count() == 3 && c1.id == 1 && c2.id == 2 && c3.id == 3) begin
            pass_count++;
            $display("  PASS: Static member count=%0d", Counter::get_count());
        end else begin
            fail_count++;
            $display("  FAIL: Static members");
        end

        // Test 9: Parameterized class
        $display("Test 9: Parameterized class");
        int_container = new();
        int_container.set(0, 42);
        int_container.set(1, 100);
        if (int_container.get(0) == 42 && int_container.get(1) == 100) begin
            pass_count++;
            $display("  PASS: Parameterized int container");
        end else begin
            fail_count++;
            $display("  FAIL: Parameterized int container");
        end

        // Test 10: Parameterized class with string type
        $display("Test 10: Parameterized class with string");
        str_container = new();
        str_container.set(0, "hello");
        str_container.set(1, "world");
        if (str_container.get(0) == "hello" && str_container.get(1) == "world") begin
            pass_count++;
            $display("  PASS: Parameterized string container");
        end else begin
            fail_count++;
            $display("  FAIL: Parameterized string container");
        end

        // Test 11: Non-virtual base method
        $display("Test 11: Non-virtual method inheritance");
        d = new("Buddy", 3);
        if (d.describe() == "Buddy is 3 years old") begin
            pass_count++;
            $display("  PASS: Non-virtual method from base");
        end else begin
            fail_count++;
            $display("  FAIL: Non-virtual method");
        end

        // Test 12: $cast dynamic type check
        $display("Test 12: Dynamic type casting");
        a = new("Generic", 1);
        d = new("Max", 4);
        a = d;
        begin
            Dog d2;
            if ($cast(d2, a)) begin
                if (d2.breed == "mixed") begin
                    pass_count++;
                    $display("  PASS: $cast to derived type");
                end else begin
                    fail_count++;
                    $display("  FAIL: $cast value incorrect");
                end
            end else begin
                fail_count++;
                $display("  FAIL: $cast failed");
            end
        end

        // Summary
        $display("");
        $display("=== Summary ===");
        $display("Pass: %0d, Fail: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
