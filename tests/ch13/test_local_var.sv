/*
:name: test_local_var
:description: Local Variable Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 9.3.1 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_var.expected
*/
// IEEE 1800-2023 Section 13 - Local Variable Tests
module test_local_var;
    int pass_count = 0;
    int fail_count = 0;

    int global_var = 100;

    function int test_local();
        int local_var;
        local_var = 50;
        return local_var;
    endfunction

    function int use_global();
        return global_var * 2;
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Local Variable Tests ===");

        // Test 1: Simple local
        $display("Test 1: Simple local");
        result = test_local();
        if (result == 50) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Global unchanged
        $display("Test 2: Global unchanged");
        result = test_local();
        if (global_var == 100) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", global_var); fail_count++; end

        // Test 3: Use global
        $display("Test 3: Use global");
        result = use_global();
        if (result == 200) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Modify global
        $display("Test 4: Modify global");
        global_var = 50;
        result = use_global();
        if (result == 100) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Local in begin block
        $display("Test 5: Block local");
        begin
            int block_var;
            block_var = 30;
            result = block_var;
        end
        if (result == 30) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Nested blocks
        $display("Test 6: Nested blocks");
        begin
            int outer;
            outer = 10;
            begin
                int inner;
                inner = 20;
                result = outer + inner;
            end
        end
        if (result == 30) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Loop local
        $display("Test 7: Loop local");
        result = 0;
        for (int i = 0; i < 5; i++) begin
            int loop_var;
            loop_var = i;
            result = result + loop_var;
        end
        if (result == 10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Multiple calls
        $display("Test 8: Multiple calls");
        result = test_local() + test_local();
        if (result == 100) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
