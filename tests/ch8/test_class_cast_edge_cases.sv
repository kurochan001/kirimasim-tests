/*
:name: test_class_cast_edge_cases
:description: Test: Class cast edge cases
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_cast_edge_cases.expected
*/
// Test: Class cast edge cases
// IEEE 1800-2023 Section 8.15 Class handles
// Tests corner cases: $cast and type checking

`timescale 1ns/1ps

class ParentClass;
    int parent_id;
    
    function new(int id = 0);
        parent_id = id;
    endfunction
endclass

class ChildClass extends ParentClass;
    int child_id;
    
    function new(int pid = 0, int cid = 0);
        super.new(pid);
        child_id = cid;
    endfunction
endclass

class OtherClass;
    int other_id;
    
    function new(int id = 0);
        other_id = id;
    endfunction
endclass

module test_class_cast_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        ParentClass parent;
        ChildClass child;
        OtherClass other;
        
        $display("TEST: Class cast edge cases");

        // Test 1: Upcast implicit
        begin
            child = new(10, 20);
            parent = child;
            if (parent != null && parent.parent_id == 10) begin
                $display("  [PASS] Upcast implicit");
                passed++;
            end else begin
                $display("  [FAIL] Upcast");
                failed++;
            end
        end

        // Test 2: Downcast with $cast
        begin
            ChildClass c2;
            int result;
            child = new(30, 40);
            parent = child;
            result = $cast(c2, parent);
            if (result == 1 && c2.child_id == 40) begin
                $display("  [PASS] Downcast with $cast");
                passed++;
            end else begin
                $display("  [FAIL] Downcast: %0d", result);
                failed++;
            end
        end

        // Test 3: Failed cast
        begin
            ChildClass c3;
            int result;
            parent = new(50);  // Pure parent, not child
            result = $cast(c3, parent);
            if (result == 0) begin
                $display("  [PASS] Failed cast");
                passed++;
            end else begin
                $display("  [FAIL] FailCast: %0d", result);
                failed++;
            end
        end

        // Test 4: Valid cast check
        begin
            ChildClass c4;
            int result;
            child = new(55, 66);
            parent = child;
            result = $cast(c4, parent);
            if (result == 1) begin
                $display("  [PASS] Valid cast check");
                passed++;
            end else begin
                $display("  [FAIL] ValidCast");
                failed++;
            end
        end

        // Test 5: Cast preserves data
        begin
            ChildClass c5;
            int result;
            child = new(100, 200);
            parent = child;
            result = $cast(c5, parent);
            if (c5.parent_id == 100 && c5.child_id == 200) begin
                $display("  [PASS] Cast preserves data");
                passed++;
            end else begin
                $display("  [FAIL] Preserve: %0d %0d", c5.parent_id, c5.child_id);
                failed++;
            end
        end

        // Test 6: Multiple casts
        begin
            ChildClass c6a, c6b;
            int r1, r2;
            child = new(1, 2);
            parent = child;
            r1 = $cast(c6a, parent);
            r2 = $cast(c6b, parent);
            if (r1 == 1 && r2 == 1 && c6a.child_id == c6b.child_id) begin
                $display("  [PASS] Multiple casts");
                passed++;
            end else begin
                $display("  [FAIL] MultiCast");
                failed++;
            end
        end

        // Test 7: Cast value verification
        begin
            ChildClass c7;
            int result;
            child = new(5, 6);
            parent = child;
            result = $cast(c7, parent);
            if (result == 1 && c7.parent_id == 5) begin
                $display("  [PASS] Cast value verification");
                passed++;
            end else begin
                $display("  [FAIL] CastValue");
                failed++;
            end
        end

        // Test 8: Different handles
        begin
            static ChildClass c8 = new(7, 8);
            child = new(9, 10);
            if (c8 != child) begin
                $display("  [PASS] Different handles");
                passed++;
            end else begin
                $display("  [FAIL] DiffHandle");
                failed++;
            end
        end

        // Test 9: Cast after modify
        begin
            ChildClass c9;
            int result;
            child = new(11, 12);
            parent = child;
            parent.parent_id = 99;
            result = $cast(c9, parent);
            if (c9.parent_id == 99 && c9.child_id == 12) begin
                $display("  [PASS] Cast after modify");
                passed++;
            end else begin
                $display("  [FAIL] ModCast");
                failed++;
            end
        end

        // Test 10: Same object check
        begin
            ChildClass c10;
            int result;
            child = new(13, 14);
            parent = child;
            result = $cast(c10, parent);
            child.child_id = 15;
            if (c10.child_id == 15) begin
                $display("  [PASS] Same object check");
                passed++;
            end else begin
                $display("  [FAIL] SameObj: %0d", c10.child_id);
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
        end
    end
endmodule
