/*
:name: test_enum_coverage
:description: Enum coverage test
:tags: enums
:type: simulation
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_coverage.expected
*/
// IEEE 1800-2023 Section 6.19 - Enum coverage test
// Tests: enum declaration, methods, iteration
module test_enum_coverage;
    int passed = 0;
    int failed = 0;

    typedef enum {RED, GREEN, BLUE, YELLOW} color_t;
    typedef enum logic [2:0] {IDLE=0, RUN=1, STOP=2, PAUSE=3} state_t;

    color_t color;
    state_t state;

    initial begin
        // Test enum assignment
        color = RED;
        if (color == RED) passed++; else begin failed++; $display("FAIL: color assign"); end

        // Test enum to int
        if (int'(RED) == 0) passed++; else begin failed++; $display("FAIL: RED value"); end
        if (int'(GREEN) == 1) passed++; else begin failed++; $display("FAIL: GREEN value"); end
        if (int'(BLUE) == 2) passed++; else begin failed++; $display("FAIL: BLUE value"); end

        // Test typed enum
        state = IDLE;
        if (state == IDLE) passed++; else begin failed++; $display("FAIL: state assign"); end

        // Test explicit values
        if (int'(IDLE) == 0) passed++; else begin failed++; $display("FAIL: IDLE value"); end
        if (int'(RUN) == 1) passed++; else begin failed++; $display("FAIL: RUN value"); end

        // Test enum comparison
        color = GREEN;
        if (color > RED) passed++; else begin failed++; $display("FAIL: enum compare"); end
        if (color < BLUE) passed++; else begin failed++; $display("FAIL: enum compare lt"); end

        // Test enum first/last
        color = color.first();
        if (color == RED) passed++; else begin failed++; $display("FAIL: first"); end

        color = color.last();
        if (color == YELLOW) passed++; else begin failed++; $display("FAIL: last"); end

        // Test enum next/prev
        color = GREEN;
        color = color.next();
        if (color == BLUE) passed++; else begin failed++; $display("FAIL: next"); end

        color = color.prev();
        if (color == GREEN) passed++; else begin failed++; $display("FAIL: prev"); end

        // Test enum num
        if (color.num() == 4) passed++; else begin failed++; $display("FAIL: num = %0d", color.num()); end

        // Test enum name
        color = RED;
        if (color.name() == "RED") passed++; else begin failed++; $display("FAIL: name = %s", color.name()); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d enum tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
