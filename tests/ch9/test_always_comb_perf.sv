/*
:name: test_always_comb_perf
:description: always_comb performance optimization test
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_perf.expected
*/
// IEEE 1800-2023 §9.2.2.2: always_comb performance optimization test
// Validates that optimized always_comb evaluation produces correct results
// with selective re-evaluation and dirty tracking.

module test_always_comb_perf;
    int pass_count = 0;
    int fail_count = 0;

    // -----------------------------------------------------------------------
    // Test 1: Basic always_comb vs assign equivalence
    // -----------------------------------------------------------------------
    logic [7:0] a_in, b_in;
    logic [7:0] sum_comb, sum_assign;

    always_comb begin
        sum_comb = a_in + b_in;
    end

    assign sum_assign = a_in + b_in;

    // -----------------------------------------------------------------------
    // Test 2: Multiple always_comb blocks, selective re-evaluation
    // Only block depending on changed signal should re-execute
    // -----------------------------------------------------------------------
    logic [7:0] x_in, y_in;
    logic [7:0] prod_out, diff_out;

    always_comb begin
        prod_out = x_in * y_in;
    end

    always_comb begin
        diff_out = x_in - y_in;
    end

    // -----------------------------------------------------------------------
    // Test 3: always_comb with case statement (complex LHS extraction)
    // -----------------------------------------------------------------------
    logic [1:0] sel;
    logic [7:0] mux_a, mux_b, mux_c, mux_d;
    logic [7:0] mux_out;

    always_comb begin
        case (sel)
            2'b00: mux_out = mux_a;
            2'b01: mux_out = mux_b;
            2'b10: mux_out = mux_c;
            2'b11: mux_out = mux_d;
        endcase
    end

    // -----------------------------------------------------------------------
    // Test 4: Chained always_comb (output of one feeds input of another)
    // -----------------------------------------------------------------------
    logic [7:0] chain_in;
    logic [7:0] chain_mid, chain_out;

    always_comb begin
        chain_mid = chain_in + 8'd1;
    end

    always_comb begin
        chain_out = chain_mid * 8'd2;
    end

    // -----------------------------------------------------------------------
    // Test 5: always_comb with continuous assign interaction
    // -----------------------------------------------------------------------
    logic [7:0] ca_in;
    logic [7:0] ca_wire;
    logic [7:0] ca_comb_out;

    assign ca_wire = ca_in + 8'd10;

    always_comb begin
        ca_comb_out = ca_wire + 8'd5;
    end

    // -----------------------------------------------------------------------
    // Test 6: No COMB_LOOP false positive with independent blocks
    // -----------------------------------------------------------------------
    logic [7:0] indep_a, indep_b;
    logic [7:0] indep_out_a, indep_out_b;

    always_comb begin
        indep_out_a = indep_a + 8'd1;
    end

    always_comb begin
        indep_out_b = indep_b + 8'd2;
    end

    initial begin
        // Test 1: Basic equivalence
        a_in = 8'd10;
        b_in = 8'd20;
        #1;
        if (sum_comb === sum_assign && sum_comb === 8'd30) begin
            $display("PASS: Test 1 - always_comb and assign produce same result: %0d", sum_comb);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - sum_comb=%0d, sum_assign=%0d, expected=30", sum_comb, sum_assign);
            fail_count++;
        end

        // Test 1b: Change inputs
        a_in = 8'd100;
        b_in = 8'd50;
        #1;
        if (sum_comb === 8'd150 && sum_comb === sum_assign) begin
            $display("PASS: Test 1b - Updated values correct: %0d", sum_comb);
            pass_count++;
        end else begin
            $display("FAIL: Test 1b - sum_comb=%0d, sum_assign=%0d, expected=150", sum_comb, sum_assign);
            fail_count++;
        end

        // Test 2: Multiple blocks
        x_in = 8'd6;
        y_in = 8'd3;
        #1;
        if (prod_out === 8'd18 && diff_out === 8'd3) begin
            $display("PASS: Test 2 - Multiple blocks: prod=%0d, diff=%0d", prod_out, diff_out);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - prod=%0d (exp 18), diff=%0d (exp 3)", prod_out, diff_out);
            fail_count++;
        end

        // Test 3: Case statement
        mux_a = 8'hAA; mux_b = 8'hBB; mux_c = 8'hCC; mux_d = 8'hDD;
        sel = 2'b00; #1;
        if (mux_out === 8'hAA) begin
            $display("PASS: Test 3a - Mux sel=0: %h", mux_out);
            pass_count++;
        end else begin
            $display("FAIL: Test 3a - mux_out=%h, expected=AA", mux_out);
            fail_count++;
        end

        sel = 2'b10; #1;
        if (mux_out === 8'hCC) begin
            $display("PASS: Test 3b - Mux sel=2: %h", mux_out);
            pass_count++;
        end else begin
            $display("FAIL: Test 3b - mux_out=%h, expected=CC", mux_out);
            fail_count++;
        end

        // Test 4: Chained always_comb
        chain_in = 8'd5;
        #1;
        if (chain_mid === 8'd6 && chain_out === 8'd12) begin
            $display("PASS: Test 4 - Chained: mid=%0d, out=%0d", chain_mid, chain_out);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - mid=%0d (exp 6), out=%0d (exp 12)", chain_mid, chain_out);
            fail_count++;
        end

        // Test 5: Continuous assign + always_comb
        ca_in = 8'd20;
        #1;
        if (ca_wire === 8'd30 && ca_comb_out === 8'd35) begin
            $display("PASS: Test 5 - CA+comb: wire=%0d, comb_out=%0d", ca_wire, ca_comb_out);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - wire=%0d (exp 30), comb_out=%0d (exp 35)", ca_wire, ca_comb_out);
            fail_count++;
        end

        // Test 6: Independent blocks (no COMB_LOOP)
        indep_a = 8'd10;
        indep_b = 8'd20;
        #1;
        if (indep_out_a === 8'd11 && indep_out_b === 8'd22) begin
            $display("PASS: Test 6 - Independent: a=%0d, b=%0d", indep_out_a, indep_out_b);
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - a=%0d (exp 11), b=%0d (exp 22)", indep_out_a, indep_out_b);
            fail_count++;
        end

        // Summary
        $display("\n=== always_comb Performance Optimization Test Summary ===");
        $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILURES: %0d", fail_count);

        $finish;
    end
endmodule
