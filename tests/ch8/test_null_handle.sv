/*
:name: test_null_handle
:description: Null class handle operations edge cases
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_null_handle.expected
*/
// Null class handle operations edge cases
module test_null_handle;
    int pass_count = 0;
    int total_tests = 10;

    // Test class
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
    endclass

    // Derived class
    class DerivedClass extends SimpleClass;
        int extra;

        function new(int v = 0, string n = "derived", int e = 0);
            super.new(v, n);
            extra = e;
        endfunction
    endclass

    // Test variables
    SimpleClass obj1, obj2;
    DerivedClass derived_obj;

    initial begin
        // Test 1: Uninitialized handle is null
        if (obj1 == null) begin
            $display("PASS: Uninitialized handle is null");
            pass_count++;
        end else begin
            $display("FAIL: Uninitialized handle should be null");
        end

        // Test 2: Null comparison
        obj1 = null;
        obj2 = null;
        if (obj1 == obj2) begin
            $display("PASS: Two null handles are equal");
            pass_count++;
        end else begin
            $display("FAIL: Null handles should be equal");
        end

        // Test 3: Non-null after construction
        obj1 = new(42, "test");
        if (obj1 != null) begin
            $display("PASS: Handle is non-null after construction");
            pass_count++;
        end else begin
            $display("FAIL: Handle should be non-null");
        end

        // Test 4: Null vs non-null comparison
        obj2 = null;
        if (obj1 != obj2) begin
            $display("PASS: Null and non-null handles not equal");
            pass_count++;
        end else begin
            $display("FAIL: Should be not equal");
        end

        // Test 5: Set handle to null
        obj1 = null;
        if (obj1 == null) begin
            $display("PASS: Handle set to null");
            pass_count++;
        end else begin
            $display("FAIL: Handle should be null after assignment");
        end

        // Test 6: Derived class null check
        if (derived_obj == null) begin
            $display("PASS: Derived class handle initially null");
            pass_count++;
        end else begin
            $display("FAIL: Derived handle should be null");
        end

        // Test 7: Assign derived to base (null)
        derived_obj = null;
        obj1 = derived_obj;
        if (obj1 == null) begin
            $display("PASS: Null derived assigned to base is null");
            pass_count++;
        end else begin
            $display("FAIL: Base should be null");
        end

        // Test 8: Assign non-null derived to base
        derived_obj = new(100, "child", 200);
        obj1 = derived_obj;
        if (obj1 != null && obj1.value == 100) begin
            $display("PASS: Non-null derived assigned to base");
            pass_count++;
        end else begin
            $display("FAIL: Base assignment failed");
        end

        // Test 9: Conditional on null
        obj2 = null;
        if (obj2 != null) begin
            $display("FAIL: Should not enter non-null branch");
        end else begin
            $display("PASS: Conditional correctly handles null");
            pass_count++;
        end

        // Test 10: Reassign null then non-null
        obj1 = null;
        obj1 = new(999, "reassigned");
        if (obj1 != null && obj1.value == 999) begin
            $display("PASS: Reassign from null to non-null");
            pass_count++;
        end else begin
            $display("FAIL: Reassignment failed");
        end

        if (pass_count == total_tests) $display("PASS: null_handle (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: null_handle (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
