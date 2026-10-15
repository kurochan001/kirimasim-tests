/*
:name: test_scope_resolution_edge_cases_2
:description: Scope resolution edge cases
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.7 26.3 8.10 8.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_resolution_edge_cases_2.expected
*/
// IEEE 1800-2023 §23.7: Scope resolution edge cases
// Tests for :: and hierarchical name resolution

package pkg_a;
    parameter int VALUE = 100;
    typedef logic [7:0] byte_t;

    function int get_value();
        return VALUE;
    endfunction
endpackage

package pkg_b;
    parameter int VALUE = 200;

    function int get_value();
        return VALUE;
    endfunction
endpackage

class BaseClass;
    static int class_val = 50;

    static function int get_static();
        return class_val;
    endfunction
endclass

class DerivedClass extends BaseClass;
    static int derived_val = 75;
endclass

module test_scope_resolution_edge_cases_2;
    int pass_count = 0;
    int test_count = 0;

    import pkg_a::*;

    initial begin
        // Test 1: Package parameter
        test_count++;
        if (pkg_a::VALUE == 100) begin
            pass_count++;
            $display("Test 1 PASS: pkg_a::VALUE = %0d", pkg_a::VALUE);
        end else begin
            $display("Test 1 FAIL: VALUE unexpected = %0d", pkg_a::VALUE);
        end

        // Test 2: Another package parameter
        test_count++;
        if (pkg_b::VALUE == 200) begin
            pass_count++;
            $display("Test 2 PASS: pkg_b::VALUE = %0d", pkg_b::VALUE);
        end else begin
            $display("Test 2 FAIL: pkg_b unexpected = %0d", pkg_b::VALUE);
        end

        // Test 3: Direct package access
        test_count++;
        if (pkg_b::VALUE == 200) begin
            pass_count++;
            $display("Test 3 PASS: pkg_b::VALUE = %0d", pkg_b::VALUE);
        end else begin
            $display("Test 3 FAIL: Direct unexpected = %0d", pkg_b::VALUE);
        end

        // Test 4: Package function
        test_count++;
        begin
            static int val = pkg_a::get_value();
            if (val == 100) begin
                pass_count++;
                $display("Test 4 PASS: pkg_a::get_value() = %0d", val);
            end else begin
                $display("Test 4 FAIL: Function unexpected = %0d", val);
            end
        end

        // Test 5: Package typedef
        test_count++;
        begin
            static pkg_a::byte_t b = 8'hFF;
            if (b == 8'hFF) begin
                pass_count++;
                $display("Test 5 PASS: pkg_a::byte_t = %h", b);
            end else begin
                $display("Test 5 FAIL: Typedef unexpected");
            end
        end

        // Test 6: Class static member
        test_count++;
        if (BaseClass::class_val == 50) begin
            pass_count++;
            $display("Test 6 PASS: BaseClass::class_val = %0d", BaseClass::class_val);
        end else begin
            $display("Test 6 FAIL: Static unexpected = %0d", BaseClass::class_val);
        end

        // Test 7: Class static function
        test_count++;
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = BaseClass::get_static();
            if (val == 50) begin
                pass_count++;
                $display("Test 7 PASS: get_static() = %0d", val);
            end else begin
                $display("Test 7 FAIL: Static func unexpected = %0d", val);
            end
        end

        // Test 8: Derived class static
        test_count++;
        if (DerivedClass::derived_val == 75) begin
            pass_count++;
            $display("Test 8 PASS: DerivedClass::derived_val = %0d", DerivedClass::derived_val);
        end else begin
            $display("Test 8 FAIL: Derived unexpected = %0d", DerivedClass::derived_val);
        end

        // Test 9: Modify class static
        test_count++;
        BaseClass::class_val = 60;
        if (BaseClass::class_val == 60) begin
            pass_count++;
            $display("Test 9 PASS: Modified class_val = %0d", BaseClass::class_val);
        end else begin
            $display("Test 9 FAIL: Modify unexpected = %0d", BaseClass::class_val);
        end

        // Test 10: Inherited static access
        test_count++;
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = DerivedClass::class_val;  // Inherited from BaseClass
            if (val == 60) begin
                pass_count++;
                $display("Test 10 PASS: Inherited static = %0d", val);
            end else begin
                $display("Test 10 FAIL: Inherited unexpected = %0d", val);
            end
        end

        // Test 11: Wildcard import
        test_count++;
        begin
            static byte_t imported_b = 8'hAA;  // From pkg_a::*
            if (imported_b == 8'hAA) begin
                pass_count++;
                $display("Test 11 PASS: Wildcard import = %h", imported_b);
            end else begin
                $display("Test 11 FAIL: Wildcard unexpected");
            end
        end

        // Test 12: Compare two packages
        test_count++;
        if (pkg_a::VALUE != pkg_b::VALUE) begin
            pass_count++;
            $display("Test 12 PASS: pkg_a != pkg_b");
        end else begin
            $display("Test 12 FAIL: Compare unexpected");
        end

        $display("=== Scope Resolution Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
