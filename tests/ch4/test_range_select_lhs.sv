/*
:name: test_range_select_lhs
:description: Part-select assignment with variable bounds
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_range_select_lhs.expected
*/
// IEEE 1800-2023 §11.5.1: Part-select assignment with variable bounds
module test_range_select_lhs;
    logic [31:0] data;
    logic [7:0] result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic part-select assignment using SelectExpr (already works)
        data = 32'h0;
        data[7:0] = 8'hAB;
        if (data[7:0] === 8'hAB) begin
            $display("PASS: Test 1 - Basic part-select data[7:0] = 8'hAB");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 8'hAB, got %h", data[7:0]);
            fail_count++;
        end

        // Test 2: Part-select assignment to higher bits
        data = 32'h0;
        data[15:8] = 8'hCD;
        if (data[15:8] === 8'hCD) begin
            $display("PASS: Test 2 - Part-select data[15:8] = 8'hCD");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 8'hCD, got %h", data[15:8]);
            fail_count++;
        end

        // Test 3: Multiple part-selects
        data = 32'h0;
        data[7:0] = 8'hAA;
        data[15:8] = 8'hBB;
        data[23:16] = 8'hCC;
        data[31:24] = 8'hDD;
        if (data === 32'hDDCCBBAA) begin
            $display("PASS: Test 3 - Multiple part-selects = 32'hDDCCBBAA");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 32'hDDCCBBAA, got %h", data);
            fail_count++;
        end

        // Test 4: Indexed part-select
        data = 32'h0;
        data[3+:8] = 8'hFF;
        if (data[10:3] === 8'hFF) begin
            $display("PASS: Test 4 - Indexed part-select data[3+:8] = 8'hFF");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 8'hFF, got %h", data[10:3]);
            fail_count++;
        end

        // Summary
        $display("\n=== Range Select LHS Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
