/*
:name: test_parameter_types
:description: Parameter Types Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_types.expected
*/
// IEEE 1800-2023 Section 6.20 - Parameter Types Tests
// Tests: Parameters, localparam, parameter expressions

module test_parameter_types;
    int pass_count = 0;
    int fail_count = 0;

    parameter int WIDTH = 8;
    parameter logic [7:0] INIT_VAL = 8'hAB;
    parameter int SIZE = 4;
    localparam int DOUBLE_WIDTH = WIDTH * 2;
    localparam int SQUARED = WIDTH * WIDTH;
    localparam int ARRAY_SIZE = SIZE * 2;
    localparam int COMBINED = WIDTH + SIZE;

    logic [WIDTH-1:0] data_a;
    logic [DOUBLE_WIDTH-1:0] data_b;

    initial begin
        $display("=== IEEE 1800-2023 Parameter Types Tests ===");

        // Test 1: Integer parameter
        $display("Test 1: Integer parameter");
        if (WIDTH == 8) begin
            $display("Test 1 PASS: WIDTH=%0d", WIDTH);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Logic parameter
        $display("Test 2: Logic parameter");
        if (INIT_VAL == 8'hAB) begin
            $display("Test 2 PASS: INIT_VAL=%h", INIT_VAL);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Size parameter
        $display("Test 3: Size parameter");
        if (SIZE == 4) begin
            $display("Test 3 PASS: SIZE=%0d", SIZE);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Localparam double width
        $display("Test 4: Localparam double width");
        if (DOUBLE_WIDTH == 16) begin
            $display("Test 4 PASS: DOUBLE_WIDTH=%0d", DOUBLE_WIDTH);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Localparam squared
        $display("Test 5: Localparam squared");
        if (SQUARED == 64) begin
            $display("Test 5 PASS: SQUARED=%0d", SQUARED);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Localparam array size
        $display("Test 6: Localparam array size");
        if (ARRAY_SIZE == 8) begin
            $display("Test 6 PASS: ARRAY_SIZE=%0d", ARRAY_SIZE);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Parameter in declaration
        $display("Test 7: Parameter in declaration");
        data_a = 8'hFF;
        if (data_a == 8'hFF) begin
            $display("Test 7 PASS: data_a=%h", data_a);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Double-width declaration
        $display("Test 8: Double-width parameter");
        data_b = 16'hCAFE;
        if (data_b == 16'hCAFE) begin
            $display("Test 8 PASS: data_b=%h", data_b);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
