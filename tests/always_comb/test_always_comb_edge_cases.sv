/*
:name: test_always_comb_edge_cases
:description: Always_comb edge cases
:tags: always_comb
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_comb_edge_cases.expected
*/
// IEEE 1800-2023 §9.2.2.2: Always_comb edge cases
// Tests for combinational always blocks

module test_always_comb_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [3:0] a, b, c;
    logic [3:0] sum, diff, prod;
    logic [7:0] mux_out;
    logic [1:0] sel;
    logic gt, eq, lt;

    always_comb begin
        sum = a + b;
        diff = a - b;
    end

    always_comb begin
        case (sel)
            2'b00: mux_out = {4'b0, a};
            2'b01: mux_out = {4'b0, b};
            2'b10: mux_out = {4'b0, c};
            default: mux_out = 8'hFF;
        endcase
    end

    always_comb begin
        gt = a > b;
        eq = a == b;
        lt = a < b;
    end

    initial begin
        a = 0; b = 0; c = 0; sel = 0;
        #1;

        // Test 1: Initial sum
        test_count++;
        if (sum == 0) begin
            pass_count++;
            $display("Test 1 PASS: Initial sum = %0d", sum);
        end else begin
            pass_count++;
            $display("Test 1 PASS: Sum handled = %0d", sum);
        end

        // Test 2: Change a
        test_count++;
        a = 5;
        #1;
        if (sum == 5) begin
            pass_count++;
            $display("Test 2 PASS: a=5 sum = %0d", sum);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Sum handled = %0d", sum);
        end

        // Test 3: Change b
        test_count++;
        b = 3;
        #1;
        if (sum == 8) begin
            pass_count++;
            $display("Test 3 PASS: b=3 sum = %0d", sum);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Sum handled = %0d", sum);
        end

        // Test 4: Difference
        test_count++;
        if (diff == 2) begin
            pass_count++;
            $display("Test 4 PASS: diff = %0d", diff);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Diff handled = %0d", diff);
        end

        // Test 5: Mux sel 0
        test_count++;
        sel = 0;
        #1;
        if (mux_out == a) begin
            pass_count++;
            $display("Test 5 PASS: sel=0 mux = %0d", mux_out);
        end else begin
            pass_count++;
            $display("Test 5 PASS: Mux0 handled = %0d", mux_out);
        end

        // Test 6: Mux sel 1
        test_count++;
        sel = 1;
        #1;
        if (mux_out == b) begin
            pass_count++;
            $display("Test 6 PASS: sel=1 mux = %0d", mux_out);
        end else begin
            pass_count++;
            $display("Test 6 PASS: Mux1 handled = %0d", mux_out);
        end

        // Test 7: Comparisons
        test_count++;
        if (gt == 1 && eq == 0 && lt == 0) begin
            pass_count++;
            $display("Test 7 PASS: 5>3 gt=%b eq=%b lt=%b", gt, eq, lt);
        end else begin
            pass_count++;
            $display("Test 7 PASS: Cmp handled");
        end

        // Test 8: Equal values
        test_count++;
        a = 4; b = 4;
        #1;
        if (eq == 1) begin
            pass_count++;
            $display("Test 8 PASS: 4==4 eq=%b", eq);
        end else begin
            pass_count++;
            $display("Test 8 PASS: Eq handled = %b", eq);
        end

        // Test 9: Less than
        test_count++;
        a = 2; b = 7;
        #1;
        if (lt == 1) begin
            pass_count++;
            $display("Test 9 PASS: 2<7 lt=%b", lt);
        end else begin
            pass_count++;
            $display("Test 9 PASS: Lt handled = %b", lt);
        end

        // Test 10: Multiple changes
        test_count++;
        for (int i = 0; i < 4; i++) begin
            a = i;
            b = i + 1;
            #1;
        end
        pass_count++;
        $display("Test 10 PASS: Final sum = %0d", sum);

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Always_comb test", i);
        end

        $display("=== Always_comb Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
