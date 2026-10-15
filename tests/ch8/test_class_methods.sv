/*
:name: test_class_methods
:description: Class methods, constructor default arguments and inherited methods (IEEE 1800-2023 Sections 8.6, 8.7 and 8.13)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 8.7 8.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_methods.expected
*/
// IEEE 1800-2023 Sections 8.6, 8.7 and 8.13

class SimpleClass;
    int value;
    string name;
    
    function new(int v = 0, string n = "default");
        value = v;
        name = n;
    endfunction
    
    function int get_value();
        return value;
    endfunction
    
    function void set_value(int v);
        value = v;
    endfunction
    
    function string get_name();
        return name;
    endfunction
    
    function int double_value();
        return value * 2;
    endfunction
endclass

class DerivedClass extends SimpleClass;
    int extra;
    
    function new(int v, string n, int e);
        super.new(v, n);
        extra = e;
    endfunction
    
    function int get_total();
        return value + extra;
    endfunction
endclass

module test_class_methods;
    SimpleClass obj1, obj2;
    DerivedClass derived;
    
    initial begin
        // Test 1: Object creation with new
        obj1 = new(10, "first");
        if (obj1 != null)
            $display("PASS: Object creation with new");
        else
            $display("FAIL: Object creation");
            
        // Test 2: Get method
        if (obj1.get_value() == 10)
            $display("PASS: get_value() = %0d", obj1.get_value());
        else
            $display("FAIL: get_value() got %0d", obj1.get_value());
            
        // Test 3: Set method
        obj1.set_value(20);
        if (obj1.get_value() == 20)
            $display("PASS: set_value() worked");
        else
            $display("FAIL: set_value() got %0d", obj1.get_value());
            
        // Test 4: String method
        if (obj1.get_name() == "first")
            $display("PASS: get_name() = %s", obj1.get_name());
        else
            $display("FAIL: get_name() got %s", obj1.get_name());
            
        // Test 5: Method returning computed value
        obj1.set_value(5);
        if (obj1.double_value() == 10)
            $display("PASS: double_value() = %0d", obj1.double_value());
        else
            $display("FAIL: double_value() got %0d", obj1.double_value());
            
        // Test 6: Default constructor
        obj2 = new();
        if (obj2.get_value() == 0 && obj2.get_name() == "default")
            $display("PASS: Default constructor");
        else
            $display("FAIL: Default constructor");
            
        // Test 7: Derived class
        derived = new(100, "derived", 50);
        if (derived.get_total() == 150)
            $display("PASS: Derived class get_total() = %0d", derived.get_total());
        else
            $display("FAIL: Derived class got %0d", derived.get_total());
            
        // Test 8: Inherited method
        if (derived.get_value() == 100)
            $display("PASS: Inherited get_value() = %0d", derived.get_value());
        else
            $display("FAIL: Inherited got %0d", derived.get_value());
        
        $display("TEST PASSED: class methods completed");
        $finish;
    end
endmodule
