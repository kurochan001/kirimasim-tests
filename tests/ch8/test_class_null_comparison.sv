/*
:name: test_class_null_comparison
:description: Class handles: null by default, compared with null, copied by assignment (IEEE 1800-2023 Sections 8.4 and 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_null_comparison.expected
*/
// IEEE 1800-2023 Sections 8.4 and 8.12 - Class Null Comparison
// Tests class handle null assignment and comparison

class SimpleClass;
    int value;
    function new(int v = 0);
        value = v;
    endfunction
endclass

module test_class_null_comparison;
    SimpleClass obj1, obj2, obj3;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Uninitialized objects are null
        if (obj1 == null) begin
            $display("PASS: Uninitialized obj1 == null");
            pass_count++;
        end else begin
            $display("FAIL: Uninitialized obj1 should be null");
            fail_count++;
        end

        // Test 2: After construction, object is not null
        obj1 = new(42);
        if (obj1 != null) begin
            $display("PASS: Constructed obj1 != null");
            pass_count++;
        end else begin
            $display("FAIL: Constructed obj1 should not be null");
            fail_count++;
        end

        // Test 3: Verify object value
        if (obj1.value == 42) begin
            $display("PASS: obj1.value = 42");
            pass_count++;
        end else begin
            $display("FAIL: obj1.value = %0d, expected 42", obj1.value);
            fail_count++;
        end

        // Test 4: Second object is still null
        if (obj2 == null) begin
            $display("PASS: obj2 == null");
            pass_count++;
        end else begin
            $display("FAIL: obj2 should be null");
            fail_count++;
        end

        // Test 5: Assignment copies reference
        obj2 = obj1;
        if (obj2 != null && obj2.value == 42) begin
            $display("PASS: obj2 = obj1 copies reference");
            pass_count++;
        end else begin
            $display("FAIL: obj2 should reference obj1");
            fail_count++;
        end

        // Test 6: Assign null to obj1
        obj1 = null;
        if (obj1 == null) begin
            $display("PASS: After obj1 = null, obj1 == null");
            pass_count++;
        end else begin
            $display("FAIL: obj1 should be null after assignment");
            fail_count++;
        end

        // Test 7: obj2 still references original object
        if (obj2 != null && obj2.value == 42) begin
            $display("PASS: obj2 still references original object");
            pass_count++;
        end else begin
            $display("FAIL: obj2 should still reference original object");
            fail_count++;
        end

        // Test 8: Create new object
        obj3 = new(100);
        if (obj3 != null && obj3.value == 100) begin
            $display("PASS: obj3 created with value 100");
            pass_count++;
        end else begin
            $display("FAIL: obj3 creation failed");
            fail_count++;
        end

        // Test 9: Multiple null assignments
        obj2 = null;
        obj3 = null;
        if (obj2 == null && obj3 == null) begin
            $display("PASS: Multiple null assignments work");
            pass_count++;
        end else begin
            $display("FAIL: Multiple null assignments failed");
            fail_count++;
        end

        $display("");
        $display("=== Class Null Comparison Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
