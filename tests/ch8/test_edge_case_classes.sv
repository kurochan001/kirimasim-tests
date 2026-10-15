/*
:name: test_edge_case_classes
:description: Corner case tests for class operations
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.9 8.16 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_case_classes.expected
*/
// Corner case tests for class operations
module test_edge_case_classes;
    int errors = 0;

    // Base class with various features
    class Base;
        int value;
        static int instance_count = 0;

        function new(int v = 0);
            value = v;
            instance_count++;
        endfunction

        virtual function int get_value();
            return value;
        endfunction

        virtual function void set_value(int v);
            value = v;
        endfunction

        static function int get_count();
            return instance_count;
        endfunction
    endclass

    // Derived class
    class Derived extends Base;
        int extra;

        function new(int v = 0, int e = 0);
            super.new(v);
            extra = e;
        endfunction

        virtual function int get_value();
            return value + extra;
        endfunction
    endclass

    // Class with copy
    class Copyable;
        int data;

        function new(int d = 0);
            data = d;
        endfunction

        function Copyable copy();
            Copyable c = new();
            c.data = this.data;
            return c;
        endfunction
    endclass

    initial begin
        Base b1, b2;
        Derived d1, d2;
        Copyable c1, c2;
        Base base_ref;

        // Test 1: Null object check
        if (b1 != null) begin
            $display("FAIL: Uninitialized object should be null");
            errors++;
        end

        // Test 2: Basic instantiation
        b1 = new(10);
        if (b1 == null) begin
            $display("FAIL: After new, object should not be null");
            errors++;
        end
        if (b1.value !== 10) begin
            $display("FAIL: value should be 10");
            errors++;
        end

        // Test 3: Static member across instances
        b2 = new(20);
        if (Base::instance_count < 2) begin
            $display("FAIL: instance_count should be at least 2");
            errors++;
        end

        // Test 4: Polymorphism
        d1 = new(10, 5);
        base_ref = d1;  // Assign derived to base reference
        if (base_ref.get_value() !== 15) begin  // Should call Derived::get_value
            $display("FAIL: Virtual call should return 15, got %0d", base_ref.get_value());
            errors++;
        end

        // Test 5: $cast for downcasting
        d2 = null;
        if (!$cast(d2, base_ref)) begin
            $display("FAIL: $cast from Base to Derived should succeed");
            errors++;
        end
        if (d2.extra !== 5) begin
            $display("FAIL: After cast, extra should be 5");
            errors++;
        end

        // Test 6: Failed cast
        b1 = new(100);
        if ($cast(d2, b1)) begin
            $display("FAIL: $cast from pure Base to Derived should fail");
            errors++;
        end

        // Test 7: Object comparison
        b1 = new(50);
        b2 = b1;  // Same reference
        if (b1 != b2) begin
            $display("FAIL: Same reference should be equal");
            errors++;
        end

        // Test 8: Different objects with same value
        b1 = new(50);
        b2 = new(50);
        if (b1 == b2) begin
            $display("FAIL: Different objects should not be equal (reference comparison)");
            errors++;
        end

        // Test 9: Copy operation
        c1 = new(999);
        c2 = c1.copy();
        if (c2.data !== 999) begin
            $display("FAIL: Copied data should be 999");
            errors++;
        end
        c1.data = 111;
        if (c2.data !== 999) begin
            $display("FAIL: Copy should be independent, got %0d", c2.data);
            errors++;
        end

        // Test 10: this reference
        b1 = new(42);
        b1.set_value(b1.get_value() + 8);
        if (b1.value !== 50) begin
            $display("FAIL: After set_value, value should be 50");
            errors++;
        end

        // Test 11: Static function call
        if (Base::get_count() < 1) begin
            $display("FAIL: Static get_count should return count");
            errors++;
        end

        // Test 12: Default argument in constructor
        b1 = new();  // Use default value = 0
        if (b1.value !== 0) begin
            $display("FAIL: Default constructor should set value to 0");
            errors++;
        end

        if (errors == 0) begin
            $display("TEST PASSED: Class edge case tests passed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
