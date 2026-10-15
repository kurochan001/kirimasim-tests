/*
:name: test_class_inheritance_corner
:description: Tests single and multi-level inheritance, method override, super
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.15 8.20 8.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inheritance_corner.expected
*/
// Tests single and multi-level inheritance, method override, super
`timescale 1ns/1ps

module test_class_inheritance_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Base class
    class Animal;
        string name;
        int age;

        function new(string n, int a);
            name = n;
            age = a;
        endfunction

        virtual function string speak();
            return "...";
        endfunction

        virtual function string describe();
            return $sformatf("%s is %0d years old", name, age);
        endfunction
    endclass

    // Derived class
    class Dog extends Animal;
        string breed;

        function new(string n, int a, string b);
            super.new(n, a);
            breed = b;
        endfunction

        virtual function string speak();
            return "Woof!";
        endfunction

        virtual function string describe();
            return {super.describe(), $sformatf(" and is a %s", breed)};
        endfunction
    endclass

    // Further derived
    class Puppy extends Dog;
        function new(string n, string b);
            super.new(n, 1, b);
        endfunction

        virtual function string speak();
            return "Yip!";
        endfunction
    endclass

    // Test 1: Basic inheritance
    task test_basic_inheritance();
        static Dog d = new("Rex", 5, "German Shepherd");

        if (d.name == "Rex" && d.age == 5 && d.breed == "German Shepherd") begin
            $display("PASS: Basic inheritance works");
            pass_count++;
        end else begin
            $display("FAIL: Basic inheritance failed");
            fail_count++;
        end
    endtask

    // Test 2: Virtual method override
    task test_virtual_override();
        static Animal a = new("Generic", 3);
        static Dog d = new("Rex", 5, "Labrador");

        if (a.speak() == "..." && d.speak() == "Woof!") begin
            $display("PASS: Virtual method override works");
            pass_count++;
        end else begin
            $display("FAIL: Virtual override failed");
            fail_count++;
        end
    endtask

    // Test 3: Super call
    task test_super_call();
        static Dog d = new("Rex", 5, "Poodle");
        static string desc;
        // Assigned here: a static initializer runs before the others in no
        // guaranteed order relative to the handle it reads (6.21).
        desc = d.describe();

        if (desc == "Rex is 5 years old and is a Poodle") begin
            $display("PASS: super.method() works: %s", desc);
            pass_count++;
        end else begin
            $display("FAIL: super.method() failed: %s", desc);
            fail_count++;
        end
    endtask

    // Test 4: Multi-level inheritance
    task test_multilevel();
        static Puppy p = new("Spot", "Beagle");

        if (p.age == 1 && p.breed == "Beagle" && p.speak() == "Yip!") begin
            $display("PASS: Multi-level inheritance works");
            pass_count++;
        end else begin
            $display("FAIL: Multi-level inheritance failed");
            fail_count++;
        end
    endtask

    // Test 5: Polymorphism
    task test_polymorphism();
        Animal animals[3];
        animals[0] = new("Generic", 10);
        animals[1] = Dog::new("Rex", 5, "Lab");
        animals[2] = Puppy::new("Spot", "Beagle");

        if (animals[0].speak() == "..." &&
            animals[1].speak() == "Woof!" &&
            animals[2].speak() == "Yip!") begin
            $display("PASS: Polymorphism works");
            pass_count++;
        end else begin
            $display("FAIL: Polymorphism failed");
            fail_count++;
        end
    endtask

    // Test 6: Type casting with $cast
    task test_casting();
        Animal a;
        static Dog d = new("Rex", 5, "Husky");
        Dog d2;

        a = d; // Upcast (always safe)

        if ($cast(d2, a)) begin
            if (d2.breed == "Husky") begin
                $display("PASS: $cast downcast works");
                pass_count++;
            end else begin
                $display("FAIL: $cast downcast wrong data");
                fail_count++;
            end
        end else begin
            $display("FAIL: $cast downcast failed");
            fail_count++;
        end
    endtask

    // Test 7: Failed cast
    task test_failed_cast();
        static Animal a = new("Generic", 5);
        Dog d;

        if (!$cast(d, a)) begin
            $display("PASS: $cast correctly fails for non-Dog Animal");
            pass_count++;
        end else begin
            $display("FAIL: $cast should have failed");
            fail_count++;
        end
    endtask

    // Abstract class concept
    virtual class Shape;
        pure virtual function real area();
        pure virtual function string name();
    endclass

    class Circle extends Shape;
        real radius;

        function new(real r);
            radius = r;
        endfunction

        virtual function real area();
            return 3.14159 * radius * radius;
        endfunction

        virtual function string name();
            return "Circle";
        endfunction
    endclass

    // Test 8: Virtual class (abstract)
    task test_virtual_class();
        static Circle c = new(5.0);

        if (c.name() == "Circle" && c.area() > 78.0 && c.area() < 79.0) begin
            $display("PASS: Virtual/abstract class works, area=%f", c.area());
            pass_count++;
        end else begin
            $display("FAIL: Virtual class failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Class Inheritance Corner Cases Test ===");

        test_basic_inheritance();
        test_virtual_override();
        test_super_call();
        test_multilevel();
        test_polymorphism();
        test_casting();
        test_failed_cast();
        test_virtual_class();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
