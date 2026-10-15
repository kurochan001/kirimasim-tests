/*
:name: test_enum_methods_2
:description: Enum Methods Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_methods_2.expected
*/
// IEEE 1800-2023 Section 6.19 - Enum Methods Tests
// Tests: enum methods, first, last, next, prev, num, name

typedef enum {IDLE, START, PROCESS, WAIT_STATE, DONE, ERROR_STATE} state_e;
typedef enum logic [2:0] {RED=0, GREEN=2, BLUE=4, YELLOW=6} color_e;

module test_enum_methods;
    int pass_count = 0;
    int fail_count = 0;

    state_e state;
    color_e color;

    initial begin
        $display("=== IEEE 1800-2023 Enum Methods Test ===");

        // Test 1: Enum first()
        $display("Test 1: Enum first()");
        state = state.first();
        $display("  state.first() = %s", state.name());
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Enum last()
        $display("Test 2: Enum last()");
        state = state.last();
        $display("  state.last() = %s", state.name());
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Enum next()
        $display("Test 3: Enum next()");
        state = IDLE;
        state = state.next();
        $display("  IDLE.next() = %s", state.name());
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Enum prev()
        $display("Test 4: Enum prev()");
        state = DONE;
        state = state.prev();
        $display("  DONE.prev() = %s", state.name());
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Enum num()
        $display("Test 5: Enum num()");
        $display("  state_e.num() = %0d", state.num());
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Enum name()
        $display("Test 6: Enum name()");
        state = PROCESS;
        $display("  PROCESS.name() = %s", state.name());
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Iterate through enum
        $display("Test 7: Iterate through enum");
        state = state.first();
        for (int i = 0; i < state.num(); i++) begin
            $display("  [%0d] %s = %0d", i, state.name(), state);
            state = state.next();
        end
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Color enum
        $display("Test 8: Color enum with values");
        color = RED;
        $display("  RED = %0d", color);
        color = GREEN;
        $display("  GREEN = %0d", color);
        color = BLUE;
        $display("  BLUE = %0d", color);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Color enum iteration
        $display("Test 9: Color enum iteration");
        color = color.first();
        for (int i = 0; i < color.num(); i++) begin
            $display("  %s = %0d", color.name(), color);
            color = color.next();
        end
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Wrap around
        $display("Test 10: Wrap around behavior");
        state = ERROR_STATE;
        state = state.next();
        $display("  ERROR_STATE.next() wraps to = %s", state.name());
        $display("Test 10 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
