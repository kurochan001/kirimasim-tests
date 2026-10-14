/*
:name: test_param
:description: Test for parameters
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param.expected
*/
// Test for parameters
// IEEE 1800-2023 §6.20

module test_param;
    parameter WIDTH = 8;
    parameter DEPTH = 4;
    localparam TOTAL = WIDTH * DEPTH;
    localparam string NAME = "test";

    logic [WIDTH-1:0] data;
    logic [TOTAL-1:0] wide;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Parameter width
        test_count++;
        if (WIDTH == 8) begin
            $display("Test 1: Parameter width PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Parameter depth
        test_count++;
        if (DEPTH == 4) begin
            $display("Test 2: Parameter depth PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Localparam calculation
        test_count++;
        if (TOTAL == 32) begin
            $display("Test 3: Localparam calculation PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Parameter in declaration
        test_count++;
        data = 8'hFF;
        if (data == 8'hFF) begin
            $display("Test 4: Parameter in declaration PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: String parameter
        test_count++;
        if (NAME == "test") begin
            $display("Test 5: String parameter PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
