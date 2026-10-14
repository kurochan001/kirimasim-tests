/*
:name: test_always_comb_cascade_propagation
:description: always_comb cascade chain propagation
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 4.4.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_cascade_propagation.expected
*/
// IEEE 1800-2023 §9.2.2.2: always_comb cascade chain propagation
// A chain of always_comb procedures settles within the Active region, so the
// final values are visible to a process that resumes after #0 (4.4.2.3).
module test_always_comb_cascade_propagation;
    logic [7:0] a, b, c, d;
    int pass_count = 0;
    int fail_count = 0;

    // 3-stage cascade chain: a -> b -> c -> d
    always_comb b = a + 1;
    always_comb c = b + 1;
    always_comb d = c + 1;

    initial begin
        // Test 1: Initial value propagation
        a = 0;
        #1;
        if (d == 8'h03) begin
            $display("PASS: Initial cascade propagation (d=%h)", d);
            pass_count++;
        end else begin
            $display("FAIL: Initial cascade (expected d=03, got d=%h)", d);
            fail_count++;
        end

        // Test 2: Cascade propagation after assignment
        a = 8'h10;
        #0;
        if (b == 8'h11 && c == 8'h12 && d == 8'h13) begin
            $display("PASS: Cascade chain a=%h b=%h c=%h d=%h", a, b, c, d);
            pass_count++;
        end else begin
            $display("FAIL: Cascade chain a=%h b=%h c=%h d=%h (expected 10 11 12 13)", a, b, c, d);
            fail_count++;
        end

        // Test 3: Second update propagation
        a = 8'hFF;
        #0;
        if (b == 8'h00 && c == 8'h01 && d == 8'h02) begin
            $display("PASS: Overflow cascade a=%h b=%h c=%h d=%h", a, b, c, d);
            pass_count++;
        end else begin
            $display("FAIL: Overflow cascade a=%h b=%h c=%h d=%h (expected FF 00 01 02)", a, b, c, d);
            fail_count++;
        end

        if (fail_count == 0)
            $display("ALL TESTS PASSED (%0d tests)", pass_count);
        else
            $display("FAILED: %0d of %0d tests", fail_count, pass_count + fail_count);
        $finish;
    end
endmodule
