/*
:name: test_array_reduction_xor
:description: Array reduction method - xor()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_xor.expected
*/
// IEEE 1800-2023 §7.12.3: Array reduction method - xor()
module test_array_reduction_xor;
    logic [7:0] arr[4] = '{8'hAA, 8'h55, 8'hFF, 8'h00};
    logic [7:0] arr2[2] = '{8'hFF, 8'hFF};
    logic [7:0] dyn[];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] result;

        // Test 1: XOR mixed values
        result = arr.xor();
        // AA ^ 55 = FF, FF ^ FF = 00, 00 ^ 00 = 00
        if (result == 8'h00) begin $display("Test 1 PASS: xor=%02h", result); pass_count++; end
        else begin $display("Test 1 FAIL: expected 00, got %02h", result); fail_count++; end

        // Test 2: XOR same values (should be 0)
        result = arr2.xor();
        if (result == 8'h00) begin $display("Test 2 PASS: xor=%02h", result); pass_count++; end
        else begin $display("Test 2 FAIL: expected 00, got %02h", result); fail_count++; end

        // Test 3: Dynamic array xor
        dyn = new[3];
        dyn[0] = 8'h0F; dyn[1] = 8'hF0; dyn[2] = 8'h00;
        result = dyn.xor();
        if (result == 8'hFF) begin $display("Test 3 PASS: xor=%02h", result); pass_count++; end
        else begin $display("Test 3 FAIL: expected FF, got %02h", result); fail_count++; end

        // Test 4: Single element
        dyn = '{8'hEF};
        result = dyn.xor();
        if (result == 8'hEF) begin $display("Test 4 PASS: single=%02h", result); pass_count++; end
        else begin $display("Test 4 FAIL: expected EF, got %02h", result); fail_count++; end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
