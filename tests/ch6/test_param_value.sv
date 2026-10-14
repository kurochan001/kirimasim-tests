/*
:name: test_param_value
:description: Parameter Value Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_value.expected
*/
// IEEE 1800-2023 Section 6.20 - Parameter Value Tests
module test_param_value;
    int pass_count = 0;
    int fail_count = 0;

    parameter WIDTH = 8;
    parameter DEPTH = 4;
    parameter MAX_VAL = (1 << WIDTH) - 1;
    parameter HALF = WIDTH / 2;

    logic [WIDTH-1:0] data;
    logic [DEPTH-1:0] addr;

    initial begin
        $display("=== IEEE 1800-2023 Parameter Value Tests ===");

        // Test 1: Width param
        $display("Test 1: Width");
        if (WIDTH == 8) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", WIDTH); fail_count++; end

        // Test 2: Depth param
        $display("Test 2: Depth");
        if (DEPTH == 4) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", DEPTH); fail_count++; end

        // Test 3: Computed param
        $display("Test 3: Computed");
        if (MAX_VAL == 255) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", MAX_VAL); fail_count++; end

        // Test 4: Half param
        $display("Test 4: Half");
        if (HALF == 4) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", HALF); fail_count++; end

        // Test 5: Data width
        $display("Test 5: Data width");
        data = MAX_VAL;
        if (data == 8'hFF) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", data); fail_count++; end

        // Test 6: Addr width
        $display("Test 6: Addr width");
        addr = 4'hF;
        if (addr == 4'hF) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", addr); fail_count++; end

        // Test 7: Zero data
        $display("Test 7: Zero");
        data = 0;
        if (data == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", data); fail_count++; end

        // Test 8: Expression
        $display("Test 8: Expr");
        if (WIDTH * DEPTH == 32) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", WIDTH * DEPTH); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
