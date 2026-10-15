/*
:name: test_always_comb_3
:description: always_comb (§9.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 11.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_3.expected
*/
// IEEE 1800-2023 always_comb (§9.2.2.2)
// Tests always_comb block

module test_always_comb;
    logic [3:0] a, b;
    logic [3:0] sum;
    logic [3:0] diff;
    logic carry;
    int pass_count = 0;
    int fail_count = 0;

    // Combinational logic
    always_comb begin
        sum = a + b;
        diff = a - b;
        carry = (a + b) > 4'hF;
    end

    initial begin
        // Test 1: Initial values
        a = 4'h5;
        b = 4'h3;
        #1;

        if (sum == 4'h8) begin
            $display("PASS: 5 + 3 = %0d", sum);
            pass_count++;
        end else begin
            $display("FAIL: 5 + 3 = %0d, expected 8", sum);
            fail_count++;
        end

        if (diff == 4'h2) begin
            $display("PASS: 5 - 3 = %0d", diff);
            pass_count++;
        end else begin
            $display("FAIL: 5 - 3 = %0d, expected 2", diff);
            fail_count++;
        end

        // Test 2: Automatic update
        a = 4'hA;
        b = 4'h5;
        #1;

        if (sum == 4'hF) begin
            $display("PASS: A + 5 = %0X", sum);
            pass_count++;
        end else begin
            $display("FAIL: A + 5 = %0X, expected F", sum);
            fail_count++;
        end

        // Test 3: Sum overflow wraps around
        a = 4'hF;
        b = 4'h1;
        #1;

        if (sum == 4'h0) begin
            $display("PASS: F + 1 wraps to 0x%0X", sum);
            pass_count++;
        end else begin
            $display("FAIL: F + 1 = 0x%0X, expected 0", sum);
            fail_count++;
        end

        // Test 4: Difference with underflow
        a = 4'h1;
        b = 4'h3;
        #1;

        if (diff == 4'hE) begin
            $display("PASS: 1 - 3 wraps to 0x%0X", diff);
            pass_count++;
        end else begin
            $display("FAIL: 1 - 3 = 0x%0X, expected E", diff);
            fail_count++;
        end

        $display("");
        $display("=== always_comb Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
