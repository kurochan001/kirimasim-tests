/*
:name: test_operator_reduction
:description: Reduction operators test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_reduction.expected
*/
// Reduction operators test
module test_operator_reduction;
    logic [7:0] val;
    logic result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: AND reduction
        val = 8'hFF;
        result = &val;
        if (result == 1'b1) begin
            $display("PASS: AND reduction of 0xFF = 1");
            pass_count++;
        end else begin
            $display("FAIL: AND reduction of 0xFF, expected 1, got %b", result);
            fail_count++;
        end

        // Test 2: OR reduction
        val = 8'h00;
        result = |val;
        if (result == 1'b0) begin
            $display("PASS: OR reduction of 0x00 = 0");
            pass_count++;
        end else begin
            $display("FAIL: OR reduction of 0x00, expected 0, got %b", result);
            fail_count++;
        end

        // Test 3: XOR reduction (parity)
        val = 8'b10101010;
        result = ^val;
        if (result == 1'b0) begin
            $display("PASS: XOR reduction of 0xAA = 0 (even parity)");
            pass_count++;
        end else begin
            $display("FAIL: XOR reduction of 0xAA, expected 0, got %b", result);
            fail_count++;
        end

        // Test 4: NAND reduction
        val = 8'hFF;
        result = ~&val;
        if (result == 1'b0) begin
            $display("PASS: NAND reduction of 0xFF = 0");
            pass_count++;
        end else begin
            $display("FAIL: NAND reduction of 0xFF, expected 0, got %b", result);
            fail_count++;
        end

        // Test 5: NOR reduction
        val = 8'h01;
        result = ~|val;
        if (result == 1'b0) begin
            $display("PASS: NOR reduction of 0x01 = 0");
            pass_count++;
        end else begin
            $display("FAIL: NOR reduction of 0x01, expected 0, got %b", result);
            fail_count++;
        end

        // Summary
        $display("Reduction operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All reduction operator tests passed");
        else $display("FAIL: Some reduction operator tests failed");
        $finish;
    end
endmodule
