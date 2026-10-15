/*
:name: test_parameter_edge_cases
:description: Parameters, localparams and overridden instance parameters, checked through outputs
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 6.20.4 23.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_edge_cases.expected
*/
// IEEE 1800-2023 §6.20: Parameter edge cases
// Tests for parameter, localparam, type parameters

module parameterized_mod #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4,
    parameter logic [7:0] DEFAULT_VAL = 8'hAA
)(
    input logic clk,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        data_out <= data_in ^ DEFAULT_VAL;
    end
endmodule

module test_parameter_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic [7:0] din8, dout8;
    logic [15:0] din16, dout16;
    logic [31:0] din32, dout32;

    // Parameter values
    parameter int TEST_PARAM = 100;
    parameter string TEST_STR = "hello";
    parameter real TEST_REAL = 3.14;
    localparam int LOCAL_PARAM = 50;
    localparam int CALC_PARAM = TEST_PARAM * 2;

    // Default instance
    parameterized_mod u_default (
        .clk(clk),
        .data_in(din8),
        .data_out(dout8)
    );

    // Wide instance
    parameterized_mod #(.WIDTH(16), .DEPTH(8)) u_wide (
        .clk(clk),
        .data_in(din16),
        .data_out(dout16)
    );

    // Custom default value
    parameterized_mod #(.WIDTH(32), .DEFAULT_VAL(8'h55)) u_custom (
        .clk(clk),
        .data_in(din32),
        .data_out(dout32)
    );

    // Clock generation
    initial begin
        repeat(50) #5 clk = ~clk;
    end

    initial begin
        // Test 1: Default parameter value
        test_count++;
        if (TEST_PARAM == 100) begin
            pass_count++;
            $display("Test 1 PASS: TEST_PARAM = %0d", TEST_PARAM);
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: String parameter
        test_count++;
        if (TEST_STR == "hello") begin
            pass_count++;
            $display("Test 2 PASS: TEST_STR = %s", TEST_STR);
        end else begin
            $display("Test 2 FAIL: String unexpected");
        end

        // Test 3: Real parameter
        test_count++;
        if (TEST_REAL > 3.0 && TEST_REAL < 4.0) begin
            pass_count++;
            $display("Test 3 PASS: TEST_REAL = %f", TEST_REAL);
        end else begin
            $display("Test 3 FAIL: Real unexpected");
        end

        // Test 4: Localparam
        test_count++;
        if (LOCAL_PARAM == 50) begin
            pass_count++;
            $display("Test 4 PASS: LOCAL_PARAM = %0d", LOCAL_PARAM);
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Calculated localparam
        test_count++;
        if (CALC_PARAM == 200) begin
            pass_count++;
            $display("Test 5 PASS: CALC_PARAM = %0d", CALC_PARAM);
        end else begin
            $display("Test 5 FAIL: CALC_PARAM = %0d", CALC_PARAM);
        end

        // Test 6: Overridden widths
        test_count++;
        din8 = 8'h00;
        @(posedge clk);
        // An instance takes the WIDTH given in its parameter value assignment (23.10).
        if ($bits(u_wide.data_in) == 16 && $bits(u_custom.data_in) == 32) begin
            pass_count++;
            $display("Test 6 PASS: Overridden widths 16 and 32");
        end else begin
            $display("Test 6 FAIL: widths %0d %0d", $bits(u_wide.data_in), $bits(u_custom.data_in));
        end

        // Test 7: Default instance XOR
        test_count++;
        din8 = 8'h00;
        @(posedge clk);
        @(posedge clk);
        if (dout8 == 8'hAA) begin
            pass_count++;
            $display("Test 7 PASS: Default XOR = %h", dout8);
        end else begin
            $display("Test 7 FAIL: Default unexpected = %h", dout8);
        end

        // Test 8: Wide instance
        test_count++;
        din16 = 16'h0000;
        @(posedge clk);
        @(posedge clk);
        if (dout16 == 16'h00AA) begin
            pass_count++;
            $display("Test 8 PASS: Wide instance dout16 = %h", dout16);
        end else begin
            $display("Test 8 FAIL: Wide instance dout16 = %h", dout16);
        end

        // Test 9: Custom default value
        test_count++;
        din32 = 32'h00000000;
        @(posedge clk);
        @(posedge clk);
        if (dout32 == 32'h00000055) begin
            pass_count++;
            $display("Test 9 PASS: Custom instance dout32 = %h", dout32);
        end else begin
            $display("Test 9 FAIL: Custom instance dout32 = %h", dout32);
        end

        // Test 10: Parameter expression
        test_count++;
        begin
            localparam int EXPR = TEST_PARAM + LOCAL_PARAM;
            if (EXPR == 150) begin
                pass_count++;
                $display("Test 10 PASS: EXPR = %0d", EXPR);
            end else begin
                $display("Test 10 FAIL: EXPR wrong = %0d", EXPR);
            end
        end

        // Test 11: Parameter in condition
        test_count++;
        if (TEST_PARAM > 50) begin
            pass_count++;
            $display("Test 11 PASS: TEST_PARAM > 50");
        end else begin
            $display("Test 11 FAIL");
        end

        // Test 12: Parameter in loop
        test_count++;
        begin
            static int sum = 0;
            for (int i = 0; i < LOCAL_PARAM; i++) sum++;
            if (sum == 50) begin
                pass_count++;
                $display("Test 12 PASS: Loop count = %0d", sum);
            end else begin
                $display("Test 12 FAIL");
            end
        end

        // Test 13: Wide data test
        test_count++;
        din16 = 16'hFFFF;
        @(posedge clk);
        @(posedge clk);
        if (dout16 == 16'hFF55) begin
            pass_count++;
            $display("Test 13 PASS: Wide FFFF result = %h", dout16);
        end else begin
            $display("Test 13 FAIL: Wide FFFF result = %h", dout16);
        end

        // Test 14: 32-bit test
        test_count++;
        din32 = 32'hDEADBEEF;
        @(posedge clk);
        @(posedge clk);
        if (dout32 == 32'hDEADBEBA) begin
            pass_count++;
            $display("Test 14 PASS: 32-bit result = %h", dout32);
        end else begin
            $display("Test 14 FAIL: 32-bit result = %h", dout32);
        end

        // Test 15: Parameter array size
        test_count++;
        begin
            logic [7:0] arr [0:TEST_PARAM-1];
            arr[0] = 1;
            arr[99] = 99;
            if (arr[0] == 1 && arr[99] == 99) begin
                pass_count++;
                $display("Test 15 PASS: Array size %0d", TEST_PARAM);
            end else begin
                $display("Test 15 FAIL: Array unexpected");
            end
        end

        // Test 16: Nested parameter
        test_count++;
        begin
            localparam int NESTED = CALC_PARAM / 4;
            if (NESTED == 50) begin
                pass_count++;
                $display("Test 16 PASS: NESTED = %0d", NESTED);
            end else begin
                $display("Test 16 FAIL: Nested unexpected = %0d", NESTED);
            end
        end

        // Test 17: Bit select with parameter
        test_count++;
        begin
            logic [TEST_PARAM-1:0] wide_sig;
            wide_sig = '1;
            if (wide_sig[0] == 1 && wide_sig[99] == 1) begin
                pass_count++;
                $display("Test 17 PASS: Wide signal bits OK");
            end else begin
                $display("Test 17 FAIL: Wide signal unexpected");
            end
        end

        // Test 18: Multiple parameter use
        test_count++;
        begin
            static int result = TEST_PARAM + LOCAL_PARAM + CALC_PARAM;
            if (result == 350) begin
                pass_count++;
                $display("Test 18 PASS: Sum = %0d", result);
            end else begin
                $display("Test 18 FAIL: Sum = %0d", result);
            end
        end

        // Test 19: String parameter length
        test_count++;
        if (TEST_STR.len() == 5) begin
            pass_count++;
            $display("Test 19 PASS: String len = %0d", TEST_STR.len());
        end else begin
            $display("Test 19 FAIL: String len unexpected");
        end

        $display("=== Parameter Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
