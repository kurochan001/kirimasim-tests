/*
:name: test_port_input
:description: Input port connections
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_input.expected
*/
// Input port connections
module adder_unit (
    input logic [7:0] a,
    input logic [7:0] b,
    input logic cin,
    output logic [7:0] sum,
    output logic cout
);
    assign {cout, sum} = a + b + cin;
endmodule

module decoder (
    input logic [2:0] sel,
    output logic [7:0] out
);
    assign out = 8'b1 << sel;
endmodule

module test_port_input;
    // Test signals
    logic [7:0] val_a, val_b;
    logic carry_in;
    logic [7:0] result;
    logic carry_out;

    logic [2:0] selector;
    logic [7:0] decoded;

    // Named port connection
    adder_unit u_add1 (
        .a(val_a),
        .b(val_b),
        .cin(carry_in),
        .sum(result),
        .cout(carry_out)
    );

    // Positional port connection
    adder_unit u_add2 (
        val_a,
        val_b,
        1'b0,  // Constant input
        ,      // Open output

    );

    // Expression as input
    logic [7:0] offset;
    logic [7:0] exp_result;
    logic exp_cout;
    adder_unit u_add3 (
        .a(val_a + 8'd1),     // Expression input
        .b(val_b & 8'hF0),    // Expression input
        .cin(carry_in | 1'b0), // Expression input
        .sum(exp_result),
        .cout(exp_cout)
    );

    // Constant inputs
    logic [7:0] const_result;
    adder_unit u_const (
        .a(8'd100),
        .b(8'd55),
        .cin(1'b1),
        .sum(const_result),
        .cout()
    );

    // Decoder with input
    decoder u_dec (
        .sel(selector),
        .out(decoded)
    );

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Named port connection
        val_a = 8'd35;
        val_b = 8'd42;
        carry_in = 1'b0;
        #1;
        if (result == 8'd77 && carry_out == 1'b0) begin
            $display("PASS: Test 1 - Named port connection (35+42=77)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - result = %0d, expected 77", result);
            fail_count++;
        end

        // Test 2: Input with carry
        val_a = 8'd100;
        val_b = 8'd50;
        carry_in = 1'b1;
        #1;
        if (result == 8'd151 && carry_out == 1'b0) begin
            $display("PASS: Test 2 - Input with carry (100+50+1=151)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - result = %0d, expected 151", result);
            fail_count++;
        end

        // Test 3: Expression as input
        val_a = 8'd10;  // +1 = 11
        val_b = 8'hAB;  // & F0 = A0 = 160
        carry_in = 1'b0;
        #1;
        if (exp_result == 8'd171) begin  // 11 + 160 = 171
            $display("PASS: Test 3 - Expression as input port");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - exp_result = %0d, expected 171", exp_result);
            fail_count++;
        end

        // Test 4: Constant inputs
        #1;
        if (const_result == 8'd156) begin  // 100 + 55 + 1 = 156
            $display("PASS: Test 4 - Constant input ports");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - const_result = %0d, expected 156", const_result);
            fail_count++;
        end

        // Test 5: Decoder input variations
        selector = 3'd0;
        #1;
        if (decoded == 8'b00000001) begin
            $display("PASS: Test 5 - Decoder input sel=0");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - decoded = %b, expected 00000001", decoded);
            fail_count++;
        end

        selector = 3'd5;
        #1;
        if (decoded == 8'b00100000) begin
            $display("PASS: Test 5b - Decoder input sel=5");
            pass_count++;
        end else begin
            $display("FAIL: Test 5b - decoded = %b, expected 00100000", decoded);
            fail_count++;
        end

        $display("\n=== Input Port Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
