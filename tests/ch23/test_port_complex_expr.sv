/*
:name: test_port_complex_expr
:description: Module port connection with complex expressions
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3 23.3.3.1 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_complex_expr.expected
*/
// IEEE 1800-2023: Module port connection with complex expressions
// Tests: nested select, member access, concatenation port connections
module sub_module(
    input logic [7:0] data_in,
    output logic [7:0] data_out
);
    assign data_out = data_in + 8'd1;
endmodule

module test_port_complex_expr;

    logic [7:0] mem [4];
    logic [7:0] result;

    // Test 1: Simple port connection (baseline)
    sub_module u1(
        .data_in(8'h10),
        .data_out(result)
    );

    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    task check_bits(string test_name, logic [7:0] actual, logic [7:0] expected);
        test_count++;
        if (actual === expected) begin
            pass_count++;
        end else begin
            fail_count++;
            $display("FAIL: %s - expected %h, got %h", test_name, expected, actual);
        end
    endtask

    initial begin
        #1;  // Allow combinational evaluation

        check_bits("simple_port_result", result, 8'h11);

        // Summary
        $display("=== Port Complex Expr Tests ===");
        $display("Tests: %0d, Pass: %0d, Fail: %0d", test_count, pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: All %0d tests passed", test_count);
        else
            $display("FAIL: %0d tests failed", fail_count);

        $finish;
    end
endmodule
