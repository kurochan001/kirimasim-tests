/*
:name: test_literal_base
:description: Literal Base Formats Tests
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_literal_base.expected
*/
// IEEE 1800-2023 Section 5.7 - Literal Base Formats Tests
module test_literal_base;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] val8;
        logic [15:0] val16;
        int ival;

        $display("=== IEEE 1800-2023 Literal Base Format Tests ===");

        $display("Test 1: Decimal");
        ival = 42;
        if (ival == 42) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", ival); fail_count++; end

        $display("Test 2: Binary");
        val8 = 8'b10101010;
        if (val8 == 8'hAA) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", val8); fail_count++; end

        $display("Test 3: Octal");
        val8 = 8'o377;
        if (val8 == 8'hFF) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", val8); fail_count++; end

        $display("Test 4: Hex lower");
        val8 = 8'hff;
        if (val8 == 8'd255) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %d", val8); fail_count++; end

        $display("Test 5: Hex upper");
        val8 = 8'hFF;
        if (val8 == 8'd255) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %d", val8); fail_count++; end

        $display("Test 6: Mixed size");
        val16 = 16'h1234;
        if (val16 == 16'd4660) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %d", val16); fail_count++; end

        $display("Test 7: Negative int");
        ival = -10;
        if (ival == -10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %d", ival); fail_count++; end

        $display("Test 8: Large decimal");
        ival = 1000000;
        if (ival == 1000000) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %d", ival); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
