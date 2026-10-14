/*
:name: test_local_scope
:description: Local Scope Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_scope.expected
*/
// IEEE 1800-2023 Section 6.21 - Local Scope Tests
module test_local_scope;
    int pass_count = 0;
    int fail_count = 0;
    int global_var = 100;

    initial begin
        int local_var;

        $display("=== IEEE 1800-2023 Local Scope Tests ===");

        $display("Test 1: Global access");
        if (global_var == 100) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Local init");
        local_var = 50;
        if (local_var == 50) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Block scope");
        begin
            static int block_var = 25;
            if (block_var == 25) begin $display("Test 3 PASS"); pass_count++; end
            else begin $display("Test 3 FAIL"); fail_count++; end
        end

        $display("Test 4: Modify global");
        global_var = 200;
        if (global_var == 200) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Nested block");
        begin
            static int outer = 1;
            begin
                static int inner = 2;
                if (outer == 1 && inner == 2) begin $display("Test 5 PASS"); pass_count++; end
                else begin $display("Test 5 FAIL"); fail_count++; end
            end
        end

        $display("Test 6: Local persist");
        local_var = 75;
        if (local_var == 75) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Global persist");
        if (global_var == 200) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Combined");
        if (local_var + global_var == 275) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
