/*
:name: test_cast_function
:description: Test for IEEE 1800-2023 §6.24.2: $cast system function
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 8.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_function.expected
*/
// Test for IEEE 1800-2023 §6.24.2: $cast system function

class BaseClass;
    int base_id;

    function new(int id = 0);
        base_id = id;
    endfunction
endclass

class DerivedClass extends BaseClass;
    int derived_id;

    function new(int bid = 0, int did = 0);
        super.new(bid);
        derived_id = did;
    endfunction
endclass

class UnrelatedClass;
    int value;

    function new(int v = 0);
        value = v;
    endfunction
endclass

module test_cast_function;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        BaseClass base_obj;
        DerivedClass derived_obj;
        BaseClass ref_obj;
        DerivedClass casted_obj;
        UnrelatedClass unrelated_obj;
        int cast_result;

        $display("=== $cast System Function Test ===");

        // Create objects
        derived_obj = new(100, 200);
        unrelated_obj = new(300);

        // Test 1: Valid upcast (Derived -> Base)
        ref_obj = derived_obj;  // Implicit upcast works
        if (ref_obj != null) begin
            $display("PASS: Upcast derived_obj to base reference");
            pass_count++;
        end else begin
            $display("FAIL: Upcast failed");
            fail_count++;
        end

        // Test 2: Valid downcast with $cast
        cast_result = $cast(casted_obj, ref_obj);
        if (cast_result && casted_obj != null) begin
            $display("PASS: $cast(casted_obj, ref_obj) succeeded, derived_id=%0d", casted_obj.derived_id);
            pass_count++;
        end else begin
            $display("FAIL: $cast downcast failed");
            fail_count++;
        end

        // Test 3: Check casted object values
        if (casted_obj != null && casted_obj.base_id == 100 && casted_obj.derived_id == 200) begin
            $display("PASS: Casted object values correct");
            pass_count++;
        end else begin
            $display("FAIL: Casted object values incorrect (base_id=%0d, derived_id=%0d)",
                     casted_obj.base_id, casted_obj.derived_id);
            fail_count++;
        end

        // Test 4: Cast to base class (should succeed)
        base_obj = new(50);
        cast_result = $cast(ref_obj, derived_obj);
        if (cast_result) begin
            $display("PASS: $cast(ref_obj, derived_obj) succeeded");
            pass_count++;
        end else begin
            $display("FAIL: $cast to base should succeed");
            fail_count++;
        end

        // Test 5: Invalid cast - base to derived (base_obj is not actually DerivedClass)
        base_obj = new(999);  // Pure BaseClass instance
        cast_result = $cast(casted_obj, base_obj);
        if (!cast_result) begin
            $display("PASS: $cast(casted_obj, base_obj) correctly failed (pure base instance)");
            pass_count++;
        end else begin
            $display("FAIL: $cast should fail for pure base instance");
            fail_count++;
        end

        // Summary
        $display("\n=== $cast System Function Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
