/*
:name: test_class_polymorphic_access
:description: Virtual methods called through base-class handles to derived objects
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.22
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_polymorphic_access.expected
*/
`timescale 1ns/1ps

class Animal;
    string name;
    virtual function string speak();
        return "...";
    endfunction
endclass

class Dog extends Animal;
    function new(string n);
        name = n;
    endfunction

    virtual function string speak();
        return "Woof";
    endfunction
endclass

class Cat extends Animal;
    function new(string n);
        name = n;
    endfunction

    virtual function string speak();
        return "Meow";
    endfunction
endclass

module test_class_polymorphic_access;
    int fails = 0;

    initial begin
        Animal a;
        Dog d;
        Cat c;

        d = new("Buddy");
        c = new("Whiskers");

        // Polymorphic access
        a = d;
        if (a.speak() != "Woof") begin fails++; $display("FAIL: Dog speak"); end
        if (a.name != "Buddy") begin fails++; $display("FAIL: Dog name"); end

        a = c;
        if (a.speak() != "Meow") begin fails++; $display("FAIL: Cat speak"); end
        if (a.name != "Whiskers") begin fails++; $display("FAIL: Cat name"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
