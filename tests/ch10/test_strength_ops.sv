/*
:name: test_strength_ops
:description: Continuous assignments with drive strengths, including highz0
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_strength_ops.expected
*/
// Continuous assignments with drive strengths, including highz0
module test_strength_ops;
    wire w1, w2, w3, w4;
    reg r1, r2;
    int pass_count = 0;
    int fail_count = 0;

    // Strong drive (default)
    assign w1 = r1;

    // Weak drive strength
    assign (weak0, weak1) w2 = r1;

    // Pull strength
    assign (pull0, pull1) w3 = r1;

    // High impedance drive for 0 (valid: can only have one highz strength)
    assign (highz0, strong1) w4 = r1;

    initial begin
        // Test 1: Strong drive high
        r1 = 1'b1;
        #1;
        if (w1 == 1'b1) begin
            $display("PASS: Test 1 - Strong drive high");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Strong drive high");
            fail_count++;
        end

        // Test 2: Strong drive low
        r1 = 1'b0;
        #1;
        if (w1 == 1'b0) begin
            $display("PASS: Test 2 - Strong drive low");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Strong drive low");
            fail_count++;
        end

        // Test 3: Weak drive
        r1 = 1'b1;
        #1;
        if (w2 == 1'b1) begin
            $display("PASS: Test 3 - Weak drive high");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Weak drive high");
            fail_count++;
        end

        // Test 4: Pull drive
        r1 = 1'b0;
        #1;
        if (w3 == 1'b0) begin
            $display("PASS: Test 4 - Pull drive low");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Pull drive low");
            fail_count++;
        end

        // Test 5: Highz drive (value still propagates)
        r1 = 1'b1;
        #1;
        // The driver drives 1 with strong strength; only 0 is driven as highz.
        if (w4 === 1'b1) begin
            $display("PASS: Test 5 - Highz0 drive of a 1 gives 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Highz drive, got %b", w4);
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
