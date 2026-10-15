/*
:name: test_param_value_2
:description: Value parameters
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 23.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_value_2.expected
*/
// Value parameters
module configurable_alu #(
    parameter int OP_ADD = 0,
    parameter int OP_SUB = 1,
    parameter int OP_AND = 2,
    parameter int OP_OR  = 3,
    parameter int WIDTH = 8,
    parameter bit SIGNED_OP = 1'b0,
    parameter real SCALE_FACTOR = 1.0
) (
    input  logic [1:0] op,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result
);
    always_comb begin
        case (op)
            OP_ADD[1:0]: result = a + b;
            OP_SUB[1:0]: result = a - b;
            OP_AND[1:0]: result = a & b;
            OP_OR[1:0]:  result = a | b;
            default:     result = '0;
        endcase
    end
endmodule

module test_param_value;
    // Integer value parameters
    localparam int MY_ADD = 0;
    localparam int MY_SUB = 1;
    localparam int MY_AND = 2;
    localparam int MY_OR  = 3;

    // Real value parameter
    localparam real GAIN = 2.5;

    // Bit value parameter
    localparam bit ENABLE = 1'b1;

    // String value parameter (for reference)
    localparam string VERSION = "1.0.0";

    logic [1:0] op;
    logic [7:0] a, b, result;

    configurable_alu #(
        .OP_ADD(MY_ADD),
        .OP_SUB(MY_SUB),
        .OP_AND(MY_AND),
        .OP_OR(MY_OR),
        .WIDTH(8),
        .SIGNED_OP(1'b1),
        .SCALE_FACTOR(GAIN)
    ) u_alu (
        .op(op),
        .a(a),
        .b(b),
        .result(result)
    );

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Integer parameter - ADD operation
        op = MY_ADD[1:0];
        a = 8'd25;
        b = 8'd17;
        #1;
        if (result == 8'd42) begin
            $display("PASS: Test 1 - Integer parameter ADD (25+17=42)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - result = %0d, expected 42", result);
            fail_count++;
        end

        // Test 2: Integer parameter - SUB operation
        op = MY_SUB[1:0];
        a = 8'd100;
        b = 8'd30;
        #1;
        if (result == 8'd70) begin
            $display("PASS: Test 2 - Integer parameter SUB (100-30=70)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - result = %0d, expected 70", result);
            fail_count++;
        end

        // Test 3: Integer parameter - AND operation
        op = MY_AND[1:0];
        a = 8'hF0;
        b = 8'h3C;
        #1;
        if (result == 8'h30) begin
            $display("PASS: Test 3 - Integer parameter AND (F0 & 3C = 30)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - result = %h, expected 30", result);
            fail_count++;
        end

        // Test 4: Real value parameter check
        if (GAIN == 2.5) begin
            $display("PASS: Test 4 - Real value parameter GAIN = 2.5");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - GAIN = %f, expected 2.5", GAIN);
            fail_count++;
        end

        // Test 5: Bit value parameter check
        if (ENABLE == 1'b1) begin
            $display("PASS: Test 5 - Bit value parameter ENABLE = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - ENABLE incorrect");
            fail_count++;
        end

        // Test 6: String value parameter
        if (VERSION == "1.0.0") begin
            $display("PASS: Test 6 - String value parameter VERSION = 1.0.0");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - VERSION incorrect");
            fail_count++;
        end

        $display("\n=== Value Parameter Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
