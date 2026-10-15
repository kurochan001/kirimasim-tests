/*
:name: test_class_polymorphism_2
:description: Class Polymorphism Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.22
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_polymorphism_2.expected
*/
// IEEE 1800-2023 Section 8.20 - Class Polymorphism Tests
// Tests: Virtual methods, polymorphic calls, type checking

module test_class_polymorphism_2;
    int pass_count = 0;
    int fail_count = 0;

    // Base class
    class Animal;
        string name;

        function new(string n = "Animal");
            name = n;
        endfunction

        virtual function string speak();
            return "...";
        endfunction

        virtual function int get_legs();
            return 0;
        endfunction
    endclass

    // Derived class 1
    class Dog extends Animal;
        function new(string n = "Dog");
            super.new(n);
        endfunction

        virtual function string speak();
            return "Woof";
        endfunction

        virtual function int get_legs();
            return 4;
        endfunction
    endclass

    // Derived class 2
    class Bird extends Animal;
        function new(string n = "Bird");
            super.new(n);
        endfunction

        virtual function string speak();
            return "Tweet";
        endfunction

        virtual function int get_legs();
            return 2;
        endfunction
    endclass

    // Further derived class
    class Parrot extends Bird;
        function new(string n = "Parrot");
            super.new(n);
        endfunction

        virtual function string speak();
            return "Hello";
        endfunction
    endclass

    Animal a;
    Dog d;
    Bird b;
    Parrot p;

    initial begin
        $display("=== IEEE 1800-2023 Class Polymorphism Tests ===");

        // Test 1: Base class method
        $display("Test 1: Base class method");
        a = new("Generic");
        if (a.speak() == "...") begin
            $display("Test 1 PASS: base speak='%s'", a.speak());
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", a.speak());
            fail_count++;
        end

        // Test 2: Derived class override
        $display("Test 2: Derived class override");
        d = new("Buddy");
        if (d.speak() == "Woof") begin
            $display("Test 2 PASS: dog speak='%s'", d.speak());
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got '%s'", d.speak());
            fail_count++;
        end

        // Test 3: Polymorphic call via base reference
        $display("Test 3: Polymorphic call via base reference");
        a = d;  // Assign derived to base
        if (a.speak() == "Woof") begin
            $display("Test 3 PASS: polymorphic speak='%s'", a.speak());
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got '%s'", a.speak());
            fail_count++;
        end

        // Test 4: Another polymorphic type
        $display("Test 4: Another polymorphic type");
        b = new("Tweety");
        a = b;
        if (a.speak() == "Tweet") begin
            $display("Test 4 PASS: bird via base='%s'", a.speak());
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got '%s'", a.speak());
            fail_count++;
        end

        // Test 5: Multi-level inheritance
        $display("Test 5: Multi-level inheritance");
        p = new("Polly");
        a = p;
        if (a.speak() == "Hello") begin
            $display("Test 5 PASS: parrot via base='%s'", a.speak());
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got '%s'", a.speak());
            fail_count++;
        end

        // Test 6: Virtual method with return value
        $display("Test 6: Virtual method with return value");
        a = d;
        if (a.get_legs() == 4) begin
            $display("Test 6 PASS: dog legs=%0d", a.get_legs());
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %0d", a.get_legs());
            fail_count++;
        end

        // Test 7: Different type via base
        $display("Test 7: Different type via base");
        a = b;
        if (a.get_legs() == 2) begin
            $display("Test 7 PASS: bird legs=%0d", a.get_legs());
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %0d", a.get_legs());
            fail_count++;
        end

        // Test 8: Method call on derived through base (legs inherited behavior)
        $display("Test 8: Parrot legs via Bird inheritance");
        a = p;
        // Parrot inherits from Bird which has 2 legs
        if (a.get_legs() == 2) begin
            $display("Test 8 PASS: parrot via base has legs=%0d", a.get_legs());
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %0d", a.get_legs());
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
