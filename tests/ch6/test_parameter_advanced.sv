/*
:name: test_parameter_advanced
:description: Advanced Parameter Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20 23.10.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_advanced.expected
*/
// IEEE 1800-2023 Section 6.20 - Advanced Parameter Tests
// Tests: Parameters, localparams, parameter expressions

module parameterized_adder #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4,
    parameter logic SIGNED_OP = 1'b0
)(
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    output logic [WIDTH:0] sum
);
    assign sum = a + b;
endmodule

module test_parameter_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Parameters and localparams
    parameter int DATA_WIDTH = 16;
    parameter int ADDR_WIDTH = 8;
    localparam int TOTAL_BITS = DATA_WIDTH + ADDR_WIDTH;
    localparam int HALF_WIDTH = DATA_WIDTH / 2;

    // Parameterized module instantiation
    logic [7:0] a8, b8;
    logic [8:0] sum8;
    parameterized_adder #(.WIDTH(8), .DEPTH(2)) adder8 (
        .a(a8), .b(b8), .sum(sum8)
    );

    logic [15:0] a16, b16;
    logic [16:0] sum16;
    parameterized_adder #(.WIDTH(16), .DEPTH(4)) adder16 (
        .a(a16), .b(b16), .sum(sum16)
    );

    initial begin
        $display("=== IEEE 1800-2023 Advanced Parameter Tests ===");

        // Test 1: Parameter value
        $display("Test 1: Parameter value");
        if (DATA_WIDTH == 16) begin
            $display("Test 1 PASS: DATA_WIDTH=%0d", DATA_WIDTH);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", DATA_WIDTH);
            fail_count++;
        end

        // Test 2: Localparam expression
        $display("Test 2: Localparam expression");
        if (TOTAL_BITS == 24) begin
            $display("Test 2 PASS: TOTAL_BITS=%0d", TOTAL_BITS);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", TOTAL_BITS);
            fail_count++;
        end

        // Test 3: Localparam division
        $display("Test 3: Localparam division");
        if (HALF_WIDTH == 8) begin
            $display("Test 3 PASS: HALF_WIDTH=%0d", HALF_WIDTH);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", HALF_WIDTH);
            fail_count++;
        end

        // Test 4: Parameterized module (8-bit)
        $display("Test 4: Parameterized module (8-bit)");
        a8 = 8'h10;
        b8 = 8'h20;
        #1;
        if (sum8 == 9'h30) begin
            $display("Test 4 PASS: 8-bit adder sum=%h", sum8);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", sum8);
            fail_count++;
        end

        // Test 5: Parameterized module (16-bit)
        $display("Test 5: Parameterized module (16-bit)");
        a16 = 16'h1000;
        b16 = 16'h2000;
        #1;
        if (sum16 == 17'h3000) begin
            $display("Test 5 PASS: 16-bit adder sum=%h", sum16);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %h", sum16);
            fail_count++;
        end

        // Test 6: Overflow handling
        $display("Test 6: Overflow handling");
        a8 = 8'hFF;
        b8 = 8'h01;
        #1;
        if (sum8 == 9'h100) begin
            $display("Test 6 PASS: overflow sum=%h", sum8);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", sum8);
            fail_count++;
        end

        // Test 7: Zero addition
        $display("Test 7: Zero addition");
        a8 = 8'h00;
        b8 = 8'h00;
        #1;
        if (sum8 == 9'h00) begin
            $display("Test 7 PASS: zero sum=%h", sum8);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", sum8);
            fail_count++;
        end

        // Test 8: Address width parameter
        $display("Test 8: Address width parameter");
        if (ADDR_WIDTH == 8) begin
            $display("Test 8 PASS: ADDR_WIDTH=%0d", ADDR_WIDTH);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %0d", ADDR_WIDTH);
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
