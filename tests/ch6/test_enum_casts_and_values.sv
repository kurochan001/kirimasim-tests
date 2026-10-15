/*
:name: test_enum_casts_and_values
:description: Enum casts and numeric values (IEEE 1800-2023 Sections 6.19 and 6.19.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_casts_and_values.expected
*/
// IEEE 1800-2023 Sections 6.19 and 6.19.4 - Enum casts and numeric values
module test_enum_casts_and_values;
    int pass_count = 0;
    int fail_count = 0;

    typedef enum {RED=0, GREEN=1, BLUE=2, YELLOW=3} color_t;

    initial begin
        color_t c;
        int val;

        $display("=== IEEE 1800-2023 Enum Cast and Value Tests ===");

        // Test 1-8
        $display("Test 1: RED");
        c = RED;
        if (c == RED) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: GREEN");
        c = GREEN;
        if (c == GREEN) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Value");
        c = BLUE;
        val = c;
        if (val == 2) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", val); fail_count++; end

        $display("Test 4: Compare");
        if (RED < GREEN) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Assign from int");
        c = color_t'(3);
        if (c == YELLOW) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Zero enum");
        c = color_t'(0);
        if (c == RED) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Next");
        c = GREEN;
        c = color_t'(c + 1);
        if (c == BLUE) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: All values");
        if (RED == 0 && GREEN == 1 && BLUE == 2 && YELLOW == 3) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
