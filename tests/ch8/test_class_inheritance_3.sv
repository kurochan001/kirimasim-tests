/*
:name: test_class_inheritance_3
:description: Test: Class extends, super calls, virtual methods
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.15 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inheritance_3.expected
*/
// Test: Class extends, super calls, virtual methods
module test_class_inheritance_3;
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

        function string get_info();
            return $sformatf("%s is %0d years old", name, age);
        endfunction
    endclass

    // Derived class with super call
    class Dog extends Animal;
        string breed;

        function new(string n, int a, string b);
            super.new(n, a);
            breed = b;
        endfunction

        virtual function string speak();
            return "Woof!";
        endfunction

        function string get_breed();
            return breed;
        endfunction
    endclass

    // Another derived class
    class Cat extends Animal;
        bit indoor;

        function new(string n, int a, bit ind = 1);
            super.new(n, a);
            indoor = ind;
        endfunction

        virtual function string speak();
            return "Meow!";
        endfunction
    endclass

    // Further derived class
    class Puppy extends Dog;
        function new(string n, string b);
            super.new(n, 0, b);  // Puppies start at age 0
        endfunction

        virtual function string speak();
            return "Yip!";
        endfunction
    endclass

    Animal a;
    Dog d;
    Cat c;
    Puppy p;
    Animal poly;

    initial begin
        // Test 1: Base class instantiation
        a = new("Generic", 5);
        if (a.name == "Generic" && a.age == 5 && a.speak() == "...") begin
            $display("PASS: Base class instantiation");
            pass_count++;
        end else begin
            $display("FAIL: Base class - name=%s, age=%0d, speak=%s", a.name, a.age, a.speak());
            fail_count++;
        end

        // Test 2: Derived class with super.new
        d = new("Rex", 3, "German Shepherd");
        if (d.name == "Rex" && d.age == 3 && d.breed == "German Shepherd") begin
            $display("PASS: Derived class with super.new");
            pass_count++;
        end else begin
            $display("FAIL: Derived class - name=%s, breed=%s", d.name, d.breed);
            fail_count++;
        end

        // Test 3: Virtual method override
        if (d.speak() == "Woof!") begin
            $display("PASS: Virtual method override in Dog");
            pass_count++;
        end else begin
            $display("FAIL: Virtual override - expected 'Woof!', got '%s'", d.speak());
            fail_count++;
        end

        // Test 4: Polymorphic assignment and virtual dispatch
        c = new("Whiskers", 2);
        poly = c;  // Assign derived to base
        if (poly.speak() == "Meow!") begin
            $display("PASS: Polymorphic virtual dispatch");
            pass_count++;
        end else begin
            $display("FAIL: Polymorphic dispatch - expected 'Meow!', got '%s'", poly.speak());
            fail_count++;
        end

        // Test 5: Multi-level inheritance
        p = new("Buddy", "Labrador");
        if (p.name == "Buddy" && p.age == 0 && p.breed == "Labrador" && p.speak() == "Yip!") begin
            $display("PASS: Multi-level inheritance");
            pass_count++;
        end else begin
            $display("FAIL: Multi-level - name=%s, age=%0d, breed=%s, speak=%s",
                     p.name, p.age, p.breed, p.speak());
            fail_count++;
        end

        // Test 6: Inherited method access
        if (d.get_info() == "Rex is 3 years old") begin
            $display("PASS: Inherited method access");
            pass_count++;
        end else begin
            $display("FAIL: Inherited method - got '%s'", d.get_info());
            fail_count++;
        end

        // Summary
        $display("Class inheritance test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All inheritance tests passed");
        $finish;
    end
endmodule
