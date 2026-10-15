/*
:name: test_enum_comprehensive
:description: Enum methods first, last, num, name, next and prev, with wrap-around
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_comprehensive.expected
*/
module test_enum_comprehensive;
    // Define multiple enum types to test
    typedef enum {RED, GREEN, BLUE, YELLOW} color_t;
    typedef enum {IDLE, RUNNING, STOPPED} state_t;
    typedef enum int {A=10, B=20, C=30, D=40, E=50} int_enum_t;

    color_t color;
    state_t state;
    int_enum_t int_val;

    initial begin
        static int passed = 0;
        static int failed = 0;

        $display("========== Enum Methods Comprehensive Test ==========");

        // Test 1: first() on color_t
        color = color.first();
        if (color == RED) begin
            $display("PASS: color.first() = RED (value %0d)", color);
            passed++;
        end else begin
            $display("FAIL: color.first() expected RED, got %0d", color);
            failed++;
        end

        // Test 2: last() on color_t
        color = color.last();
        if (color == YELLOW) begin
            $display("PASS: color.last() = YELLOW (value %0d)", color);
            passed++;
        end else begin
            $display("FAIL: color.last() expected YELLOW (3), got %0d", color);
            failed++;
        end

        // Test 3: num() on color_t (should return 4)
        if (color.num() == 4) begin
            $display("PASS: color.num() = 4");
            passed++;
        end else begin
            $display("FAIL: color.num() expected 4, got %0d", color.num());
            failed++;
        end

        // Test 4: name() on color values
        color = RED;
        if (color.name() == "RED") begin
            $display("PASS: RED.name() = \"RED\"");
            passed++;
        end else begin
            $display("FAIL: RED.name() expected \"RED\", got \"%s\"", color.name());
            failed++;
        end

        color = GREEN;
        if (color.name() == "GREEN") begin
            $display("PASS: GREEN.name() = \"GREEN\"");
            passed++;
        end else begin
            $display("FAIL: GREEN.name() expected \"GREEN\", got \"%s\"", color.name());
            failed++;
        end

        // Test 5: next() on color_t
        color = GREEN;
        color = color.next();
        if (color == BLUE) begin
            $display("PASS: GREEN.next() = BLUE");
            passed++;
        end else begin
            $display("FAIL: GREEN.next() expected BLUE, got %0d", color);
            failed++;
        end

        // Test 6: prev() on color_t
        color = BLUE;
        color = color.prev();
        if (color == GREEN) begin
            $display("PASS: BLUE.prev() = GREEN");
            passed++;
        end else begin
            $display("FAIL: BLUE.prev() expected GREEN, got %0d", color);
            failed++;
        end

        // Test 7: next() with wrap (YELLOW -> RED)
        color = YELLOW;
        color = color.next();
        if (color == RED) begin
            $display("PASS: YELLOW.next() wraps to RED");
            passed++;
        end else begin
            $display("FAIL: YELLOW.next() expected RED, got %0d", color);
            failed++;
        end

        // Test 8: prev() with wrap (RED -> YELLOW)
        color = RED;
        color = color.prev();
        if (color == YELLOW) begin
            $display("PASS: RED.prev() wraps to YELLOW");
            passed++;
        end else begin
            $display("FAIL: RED.prev() expected YELLOW, got %0d", color);
            failed++;
        end

        // Test 9: num() on state_t (should return 3)
        if (state.num() == 3) begin
            $display("PASS: state.num() = 3");
            passed++;
        end else begin
            $display("FAIL: state.num() expected 3, got %0d", state.num());
            failed++;
        end

        // Test 10: first()/last() on state_t
        state = state.first();
        if (state == IDLE) begin
            $display("PASS: state.first() = IDLE");
            passed++;
        end else begin
            $display("FAIL: state.first() expected IDLE, got %0d", state);
            failed++;
        end

        state = state.last();
        if (state == STOPPED) begin
            $display("PASS: state.last() = STOPPED");
            passed++;
        end else begin
            $display("FAIL: state.last() expected STOPPED, got %0d", state);
            failed++;
        end

        // Test 11: name() on state values
        state = RUNNING;
        if (state.name() == "RUNNING") begin
            $display("PASS: RUNNING.name() = \"RUNNING\"");
            passed++;
        end else begin
            $display("FAIL: RUNNING.name() expected \"RUNNING\", got \"%s\"", state.name());
            failed++;
        end

        // Summary
        $display("========================================");
        $display("Test Summary:");
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        $display("  Total:  %0d", passed + failed);

        if (failed == 0) begin
            $display("ALL TESTS PASSED");
            $finish(0);
        end else begin
            $display("SOME TESTS FAILED");
            $finish(1);
        end
    end
endmodule
