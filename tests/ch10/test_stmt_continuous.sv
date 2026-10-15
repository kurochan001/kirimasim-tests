/*
:name: test_stmt_continuous
:description: Continuous assignments test
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_continuous.expected
*/
// Continuous assignments test
module test_continuous;
    logic [7:0] a, b, c;
    wire [7:0] sum, diff, product;
    wire [7:0] mux_out;
    wire [7:0] chain_out;
    logic sel;
    int pass_count = 0;

    // Scenario 1: Simple continuous assignment
    assign sum = a + b;

    // Scenario 2: Continuous assignment with subtraction
    assign diff = a - b;

    // Scenario 3: Continuous assignment with multiplication
    assign product = a * c;

    // Scenario 4: Conditional continuous assignment
    assign mux_out = sel ? a : b;

    // Scenario 5: Chained continuous assignment
    assign chain_out = sum + diff;

    initial begin
        // Test scenario 1
        a = 8'd20;
        b = 8'd10;
        c = 8'd3;
        sel = 0;
        #1;
        if (sum == 8'd30) pass_count++;
        else $display("FAIL: Simple continuous assignment sum=%0d", sum);

        // Test scenario 2
        if (diff == 8'd10) pass_count++;
        else $display("FAIL: Continuous assignment subtraction diff=%0d", diff);

        // Test scenario 3
        if (product == 8'd60) pass_count++;
        else $display("FAIL: Continuous assignment multiplication product=%0d", product);

        // Test scenario 4
        if (mux_out == 8'd10) pass_count++;
        else $display("FAIL: Conditional continuous assignment mux_out=%0d (sel=0)", mux_out);

        sel = 1;
        #1;
        if (mux_out == 8'd20) pass_count++;
        else $display("FAIL: Conditional continuous assignment mux_out=%0d (sel=1)", mux_out);

        // Verify chain_out = sum + diff = 30 + 10 = 40
        if (chain_out == 8'd40) pass_count++;
        else $display("FAIL: Chained continuous assignment chain_out=%0d", chain_out);

        if (pass_count == 6) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
