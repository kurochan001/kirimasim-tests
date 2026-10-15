/*
:name: test_assign_net
:description: Net continuous assign
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_net.expected
*/
// Net continuous assign
// Verifies continuous assignment to nets

module test_assign_net;
    logic a, b, c, d;
    logic [7:0] x, y;
    wire out1;
    wire out2;
    wire [7:0] sum;
    wire [7:0] mux_out;
    wire [15:0] concat;
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: Simple AND gate
    assign out1 = a & b;

    // Scenario 2: Complex expression
    assign out2 = (a | b) & (c ^ d);

    // Scenario 3: Arithmetic
    assign sum = x + y;

    // Scenario 4: Conditional (mux)
    assign mux_out = a ? x : y;

    // Scenario 5: Concatenation
    assign concat = {x, y};

    initial begin
        // Initialize
        a = 0; b = 0; c = 0; d = 0;
        x = 8'h00; y = 8'h00;

        #1;
        // Test 1: Initial state
        if (out1 === 1'b0 && out2 === 1'b0) begin
            $display("PASS: Scenario 1 - Initial state (out1=%b, out2=%b)", out1, out2);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - out1=%b, out2=%b (expected 0, 0)", out1, out2);
            fail_count++;
        end

        // Test 2: Change inputs - AND gate
        a = 1; b = 1;
        #1;
        if (out1 === 1'b1) begin
            $display("PASS: Scenario 2 - AND gate (out1=%b)", out1);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - out1=%b (expected 1)", out1);
            fail_count++;
        end

        // Test 3: Complex expression
        c = 1; d = 0; // c^d = 1
        #1;
        if (out2 === 1'b1) begin
            $display("PASS: Scenario 3 - Complex expr (out2=%b)", out2);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - out2=%b (expected 1)", out2);
            fail_count++;
        end

        // Test 4: Arithmetic
        x = 8'h0F; y = 8'h10;
        #1;
        if (sum === 8'h1F) begin
            $display("PASS: Scenario 4 - Arithmetic (sum=0x%h)", sum);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - sum=0x%h (expected 0x1F)", sum);
            fail_count++;
        end

        // Test 5: Mux (a=1, so mux_out=x)
        #1;
        if (mux_out === 8'h0F) begin
            $display("PASS: Scenario 5 - Mux a=1 (mux_out=0x%h)", mux_out);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - mux_out=0x%h (expected 0x0F)", mux_out);
            fail_count++;
        end

        // Test 6: Mux change select
        a = 0;
        #1;
        if (mux_out === 8'h10) begin
            $display("PASS: Scenario 6 - Mux a=0 (mux_out=0x%h)", mux_out);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6 - mux_out=0x%h (expected 0x10)", mux_out);
            fail_count++;
        end

        // Test 7: Concatenation
        x = 8'hAB; y = 8'hCD;
        #1;
        if (concat === 16'hABCD) begin
            $display("PASS: Scenario 7 - Concat (concat=0x%h)", concat);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 7 - concat=0x%h (expected 0xABCD)", concat);
            fail_count++;
        end

        // Summary
        $display("Net continuous assign: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
