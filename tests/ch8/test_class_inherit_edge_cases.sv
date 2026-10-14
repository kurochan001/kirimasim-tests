/*
:name: test_class_inherit_edge_cases
:description: Test: Class inheritance edge cases
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.15 6.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inherit_edge_cases.expected
*/
// Test: Class inheritance edge cases
// IEEE 1800-2023 Section 8.13 Inheritance
// Tests corner cases: class inheritance

`timescale 1ns/1ps

class BaseClass;
    int base_val;
    
    function new(int v = 0);
        base_val = v;
    endfunction
    
    function int get_base();
        return base_val;
    endfunction
endclass

class DerivedClass extends BaseClass;
    int derived_val;
    
    function new(int bv = 0, int dv = 0);
        super.new(bv);
        derived_val = dv;
    endfunction
    
    function int get_derived();
        return derived_val;
    endfunction
    
    function int get_sum();
        return base_val + derived_val;
    endfunction
endclass

module test_class_inherit_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        BaseClass base;
        DerivedClass derived;
        
        $display("TEST: Class inheritance edge cases");

        // Test 1: Base class creation
        begin
            base = new(10);
            if (base.base_val == 10) begin
                $display("  [PASS] Base class creation");
                passed++;
            end else begin
                $display("  [FAIL] Base: %0d", base.base_val);
                failed++;
            end
        end

        // Test 2: Derived class creation
        begin
            derived = new(20, 30);
            if (derived != null) begin
                $display("  [PASS] Derived class creation");
                passed++;
            end else begin
                $display("  [FAIL] Derived creation");
                failed++;
            end
        end

        // Test 3: Inherited member
        begin
            if (derived.base_val == 20) begin
                $display("  [PASS] Inherited member");
                passed++;
            end else begin
                $display("  [FAIL] Inherit: %0d", derived.base_val);
                failed++;
            end
        end

        // Test 4: New member
        begin
            if (derived.derived_val == 30) begin
                $display("  [PASS] New member");
                passed++;
            end else begin
                $display("  [FAIL] NewMem: %0d", derived.derived_val);
                failed++;
            end
        end

        // Test 5: Inherited method
        begin
            if (derived.get_base() == 20) begin
                $display("  [PASS] Inherited method");
                passed++;
            end else begin
                $display("  [FAIL] InhMethod: %0d", derived.get_base());
                failed++;
            end
        end

        // Test 6: New method
        begin
            if (derived.get_derived() == 30) begin
                $display("  [PASS] New method");
                passed++;
            end else begin
                $display("  [FAIL] NewMethod: %0d", derived.get_derived());
                failed++;
            end
        end

        // Test 7: Combined method
        begin
            if (derived.get_sum() == 50) begin
                $display("  [PASS] Combined method");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", derived.get_sum());
                failed++;
            end
        end

        // Test 8: Independent instances
        begin
            static DerivedClass d1 = new(1, 2);
            static DerivedClass d2 = new(3, 4);
            if (d1.get_sum() == 3 && d2.get_sum() == 7) begin
                $display("  [PASS] Independent instances");
                passed++;
            end else begin
                $display("  [FAIL] Indep: %0d %0d", d1.get_sum(), d2.get_sum());
                failed++;
            end
        end

        // Test 9: Default constructor
        begin
            static DerivedClass d = new();
            if (d.base_val == 0 && d.derived_val == 0) begin
                $display("  [PASS] Default constructor");
                passed++;
            end else begin
                $display("  [FAIL] DefConst");
                failed++;
            end
        end

        // Test 10: Modify inherited
        begin
            derived.base_val = 100;
            if (derived.get_base() == 100) begin
                $display("  [PASS] Modify inherited");
                passed++;
            end else begin
                $display("  [FAIL] ModInherit: %0d", derived.get_base());
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
        $finish;
        end
    end
endmodule
