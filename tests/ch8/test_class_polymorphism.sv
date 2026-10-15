/*
:name: test_class_polymorphism
:description: Class Polymorphism (§8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_polymorphism.expected
*/
// IEEE 1800-2023 Class Polymorphism (§8.20)
// Tests virtual methods and polymorphic behavior

class Animal;
    string name;

    function new(string n);
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
    function new(string n);
        super.new(n);
    endfunction

    virtual function string speak();
        return "Woof!";
    endfunction

    virtual function int get_legs();
        return 4;
    endfunction
endclass

class Cat extends Animal;
    function new(string n);
        super.new(n);
    endfunction

    virtual function string speak();
        return "Meow!";
    endfunction

    virtual function int get_legs();
        return 4;
    endfunction
endclass

class Bird extends Animal;
    function new(string n);
        super.new(n);
    endfunction

    virtual function string speak();
        return "Tweet!";
    endfunction

    virtual function int get_legs();
        return 2;
    endfunction
endclass

module test_class_polymorphism;
    initial begin
        Animal animals[3];
        static int pass_count = 0;
        static int fail_count = 0;
        Dog d;
        Cat c;
        Bird b;

        // Create instances
        d = new("Rex");
        c = new("Whiskers");
        b = new("Tweety");

        // Store in base class array
        animals[0] = d;
        animals[1] = c;
        animals[2] = b;

        // Test 1: Virtual method dispatch
        if (animals[0].speak() == "Woof!") begin
            $display("PASS: Dog speaks correctly via base pointer");
            pass_count++;
        end else begin
            $display("FAIL: Dog should say 'Woof!', got '%s'", animals[0].speak());
            fail_count++;
        end

        if (animals[1].speak() == "Meow!") begin
            $display("PASS: Cat speaks correctly via base pointer");
            pass_count++;
        end else begin
            $display("FAIL: Cat should say 'Meow!', got '%s'", animals[1].speak());
            fail_count++;
        end

        if (animals[2].speak() == "Tweet!") begin
            $display("PASS: Bird speaks correctly via base pointer");
            pass_count++;
        end else begin
            $display("FAIL: Bird should say 'Tweet!', got '%s'", animals[2].speak());
            fail_count++;
        end

        // Test 2: Another virtual method
        if (animals[0].get_legs() == 4) begin
            $display("PASS: Dog has 4 legs");
            pass_count++;
        end else begin
            $display("FAIL: Dog should have 4 legs, got %0d", animals[0].get_legs());
            fail_count++;
        end

        if (animals[2].get_legs() == 2) begin
            $display("PASS: Bird has 2 legs");
            pass_count++;
        end else begin
            $display("FAIL: Bird should have 2 legs, got %0d", animals[2].get_legs());
            fail_count++;
        end

        // Test 3: Name inheritance
        if (animals[0].name == "Rex") begin
            $display("PASS: Dog name inherited correctly");
            pass_count++;
        end else begin
            $display("FAIL: Dog name should be 'Rex', got '%s'", animals[0].name);
            fail_count++;
        end

        $display("");
        $display("=== Class Polymorphism Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
