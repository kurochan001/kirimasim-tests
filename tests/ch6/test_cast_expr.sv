/*
:name: test_cast_expr
:description: Cast Expression Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_expr.expected
*/
// IEEE 1800-2023 Section 6.24 - Cast Expression Tests
module test_cast_expr;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i;
        real r;
        logic [7:0] lv;
        logic [15:0] wv;
        bit b;

        $display("=== IEEE 1800-2023 Cast Expression Tests ===");

        // Test 1: Real to int
        $display("Test 1: Real to int");
        r = 3.7;
        i = int'(r);
        // int'() rounds to the nearest integer (6.12.1)
        if (i == 4) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", i); fail_count++; end

        // Test 2: Int to real
        $display("Test 2: Int to real");
        i = 5;
        r = real'(i);
        if (r == 5.0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %f", r); fail_count++; end

        // Test 3: Signed to unsigned
        $display("Test 3: Signed to unsigned");
        i = -1;
        lv = 8'(i);
        if (lv == 8'hFF) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", lv); fail_count++; end

        // Test 4: Width cast
        $display("Test 4: Width cast");
        lv = 8'hAB;
        wv = 16'(lv);
        if (wv == 16'h00AB) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", wv); fail_count++; end

        // Test 5: Truncation
        $display("Test 5: Truncation");
        wv = 16'h12AB;
        lv = 8'(wv);
        if (lv == 8'hAB) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", lv); fail_count++; end

        // Test 6: Bit cast
        $display("Test 6: Bit cast");
        i = 1;
        b = bit'(i);
        if (b == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", b); fail_count++; end

        // Test 7: Zero cast
        $display("Test 7: Zero cast");
        i = 0;
        b = bit'(i);
        if (b == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", b); fail_count++; end

        // Test 8: Sign extension
        $display("Test 8: Sign ext");
        lv = 8'h80;
        i = $signed(lv);
        if (i < 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", i); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
