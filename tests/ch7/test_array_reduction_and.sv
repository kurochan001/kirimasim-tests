/*
:name: test_array_reduction_and
:description: Array reduction method - and()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_and.expected
*/
// IEEE 1800-2023 §7.12.3: Array reduction method - and()
module test_array_reduction_and;
    logic [7:0] arr[4] = '{8'hFF, 8'hF0, 8'h0F, 8'h00};
    logic [7:0] arr2[3] = '{8'hFF, 8'hFF, 8'hFF};
    logic [7:0] dyn[];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] result;

        // Test 1: AND all - should be 0
        result = arr.and();
        if (result == 8'h00) begin $display("Test 1 PASS: and=%02h", result); pass_count++; end
        else begin $display("Test 1 FAIL: expected 00, got %02h", result); fail_count++; end

        // Test 2: AND all 1s - should be FF
        result = arr2.and();
        if (result == 8'hFF) begin $display("Test 2 PASS: and=%02h", result); pass_count++; end
        else begin $display("Test 2 FAIL: expected FF, got %02h", result); fail_count++; end

        // Test 3: Dynamic array and
        dyn = new[3];
        dyn[0] = 8'hF0; dyn[1] = 8'hCC; dyn[2] = 8'hAA;
        result = dyn.and();
        if (result == 8'h80) begin $display("Test 3 PASS: and=%02h", result); pass_count++; end
        else begin $display("Test 3 FAIL: expected 80, got %02h", result); fail_count++; end

        // Test 4: Single element
        dyn = '{8'hAB};
        result = dyn.and();
        if (result == 8'hAB) begin $display("Test 4 PASS: single=%02h", result); pass_count++; end
        else begin $display("Test 4 FAIL: expected AB, got %02h", result); fail_count++; end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
