/*
:name: test_class_virtual_edge_cases
:description: Test: Class virtual method edge cases
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_virtual_edge_cases.expected
*/
// Test: Class virtual method edge cases
// IEEE 1800-2023 Section 8.19 Virtual methods
// Tests corner cases: virtual methods and polymorphism

`timescale 1ns/1ps

class Animal;
    string name;
    
    function new(string n = "animal");
        name = n;
    endfunction
    
    virtual function string speak();
        return "...";
    endfunction
    
    virtual function int get_legs();
        return 0;
    endfunction
endclass

class Dog extends Animal;
    function new();
        super.new("dog");
    endfunction
    
    virtual function string speak();
        return "woof";
    endfunction
    
    virtual function int get_legs();
        return 4;
    endfunction
endclass

class Bird extends Animal;
    function new();
        super.new("bird");
    endfunction
    
    virtual function string speak();
        return "chirp";
    endfunction
    
    virtual function int get_legs();
        return 2;
    endfunction
endclass

module test_class_virtual_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        Animal a;
        Dog d;
        Bird b;
        
        $display("TEST: Class virtual method edge cases");

        // Test 1: Base virtual method
        begin
            a = new();
            if (a.speak() == "...") begin
                $display("  [PASS] Base virtual method");
                passed++;
            end else begin
                $display("  [FAIL] Base: %s", a.speak());
                failed++;
            end
        end

        // Test 2: Dog speak
        begin
            d = new();
            if (d.speak() == "woof") begin
                $display("  [PASS] Dog speak");
                passed++;
            end else begin
                $display("  [FAIL] Dog: %s", d.speak());
                failed++;
            end
        end

        // Test 3: Bird speak
        begin
            b = new();
            if (b.speak() == "chirp") begin
                $display("  [PASS] Bird speak");
                passed++;
            end else begin
                $display("  [FAIL] Bird: %s", b.speak());
                failed++;
            end
        end

        // Test 4: Dog legs
        begin
            if (d.get_legs() == 4) begin
                $display("  [PASS] Dog legs");
                passed++;
            end else begin
                $display("  [FAIL] DogLegs: %0d", d.get_legs());
                failed++;
            end
        end

        // Test 5: Bird legs
        begin
            if (b.get_legs() == 2) begin
                $display("  [PASS] Bird legs");
                passed++;
            end else begin
                $display("  [FAIL] BirdLegs: %0d", b.get_legs());
                failed++;
            end
        end

        // Test 6: Polymorphic dog
        begin
            a = d;
            if (a.speak() == "woof") begin
                $display("  [PASS] Polymorphic dog");
                passed++;
            end else begin
                $display("  [FAIL] PolyDog: %s", a.speak());
                failed++;
            end
        end

        // Test 7: Polymorphic bird
        begin
            a = b;
            if (a.speak() == "chirp") begin
                $display("  [PASS] Polymorphic bird");
                passed++;
            end else begin
                $display("  [FAIL] PolyBird: %s", a.speak());
                failed++;
            end
        end

        // Test 8: Polymorphic legs
        begin
            a = d;
            if (a.get_legs() == 4) begin
                $display("  [PASS] Polymorphic legs");
                passed++;
            end else begin
                $display("  [FAIL] PolyLegs: %0d", a.get_legs());
                failed++;
            end
        end

        // Test 9: Name inheritance
        begin
            if (d.name == "dog" && b.name == "bird") begin
                $display("  [PASS] Name inheritance");
                passed++;
            end else begin
                $display("  [FAIL] Names: %s %s", d.name, b.name);
                failed++;
            end
        end

        // Test 10: Multiple dogs
        begin
            static Dog d1 = new();
            static Dog d2 = new();
            if (d1.speak() == d2.speak()) begin
                $display("  [PASS] Multiple dogs");
                passed++;
            end else begin
                $display("  [FAIL] MultiDog");
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
