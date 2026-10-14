/*
:name: test_case_expr
:description: Case Expression Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 13.4.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_expr.expected
*/
// IEEE 1800-2023 Section 12.5 - Case Expression Tests
module test_case_expr;
    int pass_count = 0;
    int fail_count = 0;

    function automatic int select_val(int sel);
        case (sel)
            0: return 100;
            1: return 200;
            2: return 300;
            3: return 400;
            default: return -1;
        endcase
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Case Expression Tests ===");

        $display("Test 1: Case 0");
        result = select_val(0);
        if (result == 100) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: Case 1");
        result = select_val(1);
        if (result == 200) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Case 2");
        result = select_val(2);
        if (result == 300) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Case 3");
        result = select_val(3);
        if (result == 400) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Default");
        result = select_val(10);
        if (result == -1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Negative default");
        result = select_val(-5);
        if (result == -1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Large default");
        result = select_val(1000);
        if (result == -1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Compare cases");
        if (select_val(0) + select_val(1) == 300) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
