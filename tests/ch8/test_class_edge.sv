/*
:name: test_class_edge
:description: Classes: construction, methods, local members, inheritance (IEEE 1800-2023 Sections 8.4, 8.6, 8.13 and 8.18)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.6 8.13 8.18
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_edge.expected
*/
// Classes: construction, methods, local members, inheritance (IEEE 1800-2023 Sections 8.4, 8.6, 8.13 and 8.18)
module test_class_edge;
    int pass_count = 0;
    int test_count = 0;
    
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
    endclass
    
    class Counter;
        local int count;
        
        function new();
            count = 0;
        endfunction
        
        function void increment();
            count++;
        endfunction
        
        function void decrement();
            count--;
        endfunction
        
        function int get_count();
            return count;
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
    
    SimpleClass obj1, obj2;
    Counter cnt;
    DerivedClass derived;
    
    initial begin
        // Test 1: Object creation
        test_count++;
        obj1 = new(10, "test1");
        if (obj1 != null) pass_count++;
        
        // Test 2: Get value
        test_count++;
        if (obj1.get_value() == 10) pass_count++;
        
        // Test 3: Get name
        test_count++;
        if (obj1.get_name() == "test1") pass_count++;
        
        // Test 4: Set value
        test_count++;
        obj1.set_value(20);
        if (obj1.get_value() == 20) pass_count++;
        
        // Test 5: Multiple objects
        test_count++;
        obj2 = new(30, "test2");
        if (obj1.get_value() != obj2.get_value()) pass_count++;
        
        // Test 6: Counter class
        test_count++;
        cnt = new();
        cnt.increment();
        cnt.increment();
        cnt.increment();
        if (cnt.get_count() == 3) pass_count++;
        
        // Test 7: Decrement
        test_count++;
        cnt.decrement();
        if (cnt.get_count() == 2) pass_count++;
        
        // Test 8: Derived class
        test_count++;
        derived = new(10, "derived", 5);
        if (derived.get_total() == 15) pass_count++;
        
        // Test 9: Inherited method
        test_count++;
        if (derived.get_value() == 10) pass_count++;
        
        // Test 10: Default constructor args
        test_count++;
        obj1 = new();
        if (obj1.get_value() == 0) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
