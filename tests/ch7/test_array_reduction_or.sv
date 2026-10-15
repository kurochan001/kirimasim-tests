/*
:name: test_array_reduction_or
:description: Array reduction method - or()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_or.expected
*/
// IEEE 1800-2023 §7.12.3: Array reduction method - or()
module test_array_reduction_or;
    logic [7:0] arr[4] = '{8'h01, 8'h02, 8'h04, 8'h08};
    logic [7:0] arr2[3] = '{8'h00, 8'h00, 8'h00};
    logic [7:0] dyn[];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] result;

        // Test 1: OR different bits
        result = arr.or();
        if (result == 8'h0F) begin $display("Test 1 PASS: or=%02h", result); pass_count++; end
        else begin $display("Test 1 FAIL: expected 0F, got %02h", result); fail_count++; end

        // Test 2: OR all zeros
        result = arr2.or();
        if (result == 8'h00) begin $display("Test 2 PASS: or=%02h", result); pass_count++; end
        else begin $display("Test 2 FAIL: expected 00, got %02h", result); fail_count++; end

        // Test 3: Dynamic array or
        dyn = new[3];
        dyn[0] = 8'h10; dyn[1] = 8'h20; dyn[2] = 8'h40;
        result = dyn.or();
        if (result == 8'h70) begin $display("Test 3 PASS: or=%02h", result); pass_count++; end
        else begin $display("Test 3 FAIL: expected 70, got %02h", result); fail_count++; end

        // Test 4: Single element
        dyn = '{8'hCD};
        result = dyn.or();
        if (result == 8'hCD) begin $display("Test 4 PASS: single=%02h", result); pass_count++; end
        else begin $display("Test 4 FAIL: expected CD, got %02h", result); fail_count++; end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
