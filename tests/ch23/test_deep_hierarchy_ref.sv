/*
:name: test_deep_hierarchy_ref
:description: Corner Case: Deep Hierarchy References
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 23.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deep_hierarchy_ref.expected
*/
// Corner Case: Deep Hierarchy References
// Tests signal references through deeply nested module hierarchy

module level5(output int val);
    assign val = 555;

    function automatic int get_level();
        return 5;
    endfunction
endmodule

module level4(output int val);
    level5 l5(.val(val));

    int local_val = 444;

    function automatic int get_level();
        return 4;
    endfunction
endmodule

module level3(output int val);
    level4 l4(.val(val));

    int local_val = 333;

    task automatic set_deep_val(ref int target);
        target = local_val;
    endtask
endmodule

module level2(output int val);
    level3 l3(.val(val));

    int local_val = 222;
endmodule

module level1(output int val);
    level2 l2(.val(val));

    int local_val = 111;
endmodule

module top_level;
    int val;
    level1 l1(.val(val));
endmodule

module test_deep_hierarchy_ref;
    int pass_count = 0;
    int fail_count = 0;

    top_level dut();

    initial begin
        #1;

        // Test 1: Direct deep reference
        if (dut.val == 555) pass_count++;
        else begin fail_count++; $display("FAIL: direct deep ref, got %0d", dut.val); end

        // Test 2: Hierarchical path through levels
        if (dut.l1.l2.l3.l4.l5.val == 555) pass_count++;
        else begin fail_count++; $display("FAIL: full path ref"); end

        // Test 3: Partial hierarchy reference - level1
        if (dut.l1.local_val == 111) pass_count++;
        else begin fail_count++; $display("FAIL: level1 local"); end

        // Test 4: Partial hierarchy reference - level2
        if (dut.l1.l2.local_val == 222) pass_count++;
        else begin fail_count++; $display("FAIL: level2 local"); end

        // Test 5: Partial hierarchy reference - level3
        if (dut.l1.l2.l3.local_val == 333) pass_count++;
        else begin fail_count++; $display("FAIL: level3 local"); end

        // Test 6: Partial hierarchy reference - level4
        if (dut.l1.l2.l3.l4.local_val == 444) pass_count++;
        else begin fail_count++; $display("FAIL: level4 local"); end

        // Test 7: Function call through hierarchy
        begin
            static int result;
            // Assigned here: a static initializer runs before the others in no
            // guaranteed order relative to the handle it reads (the standard specifies none).
            result = dut.l1.l2.l3.l4.get_level();
            if (result == 4) pass_count++;
            else begin fail_count++; $display("FAIL: func call level4, got %0d", result); end
        end

        // Test 8: Function call at deepest level
        begin
            static int result;
            // Assigned here: a static initializer runs before the others in no
            // guaranteed order relative to the handle it reads (the standard specifies none).
            result = dut.l1.l2.l3.l4.l5.get_level();
            if (result == 5) pass_count++;
            else begin fail_count++; $display("FAIL: func call level5, got %0d", result); end
        end

        // Test 9: Modify hierarchical variable
        dut.l1.local_val = 999;
        if (dut.l1.local_val == 999) pass_count++;
        else begin fail_count++; $display("FAIL: modify hierarchical"); end

        // Test 10: Task call through hierarchy
        begin
            static int target = 0;
            dut.l1.l2.l3.set_deep_val(target);
            if (target == 333) pass_count++;
            else begin fail_count++; $display("FAIL: task call through hierarchy"); end
        end

        // Test 11: Modify deep variable
        dut.l1.l2.l3.l4.local_val = 888;
        if (dut.l1.l2.l3.l4.local_val == 888) pass_count++;
        else begin fail_count++; $display("FAIL: modify deep var"); end

        // Test 12: Restore and verify
        dut.l1.l2.l3.l4.local_val = 444;
        dut.l1.local_val = 111;
        if (dut.l1.local_val == 111 && dut.l1.l2.l3.l4.local_val == 444) pass_count++;
        else begin fail_count++; $display("FAIL: restore values"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/12)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
