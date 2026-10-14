/*
:name: test_enum_edge_cases
:description: Test: Enum edge cases
:tags: enum
:type: simulation
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_edge_cases.expected
*/
// Test: Enum edge cases
// IEEE 1800-2023 Section 6.19 Enumerations
// Tests corner cases: methods, explicit values, casting, comparison

`timescale 1ns/1ps

module test_enum_edge_cases;
    int passed = 0;
    int failed = 0;

    // Basic enum
    typedef enum {RED, GREEN, BLUE} color_t;

    // Enum with explicit values
    typedef enum int {IDLE=0, RUN=5, STOP=10} state_t;

    // Enum with gaps
    typedef enum logic [3:0] {A=1, B=3, C=7, D=15} sparse_t;

    initial begin
        $display("TEST: Enum edge cases");

        // Test 1: Enum default value
        begin
            color_t c;
            if (c == RED) begin
                $display("  [PASS] Enum default is first member");
                passed++;
            end else begin
                $display("  [FAIL] Enum default should be first member");
                failed++;
            end
        end

        // Test 2: Enum name() method
        begin
            static color_t c = GREEN;
            static string s = c.name();
            if (s == "GREEN") begin
                $display("  [PASS] Enum name() returns GREEN");
                passed++;
            end else begin
                $display("  [FAIL] Enum name() should return GREEN, got: %s", s);
                failed++;
            end
        end

        // Test 3: Enum first() method
        begin
            static color_t c = BLUE;
            static color_t first_val = c.first();
            if (first_val == RED) begin
                $display("  [PASS] Enum first() returns RED");
                passed++;
            end else begin
                $display("  [FAIL] Enum first() should return RED");
                failed++;
            end
        end

        // Test 4: Enum last() method
        begin
            static color_t c = RED;
            static color_t last_val = c.last();
            if (last_val == BLUE) begin
                $display("  [PASS] Enum last() returns BLUE");
                passed++;
            end else begin
                $display("  [FAIL] Enum last() should return BLUE");
                failed++;
            end
        end

        // Test 5: Enum next() method
        begin
            static color_t c = RED;
            static color_t next_val = c.next();
            if (next_val == GREEN) begin
                $display("  [PASS] Enum next() returns GREEN after RED");
                passed++;
            end else begin
                $display("  [FAIL] Enum next() should return GREEN after RED");
                failed++;
            end
        end

        // Test 6: Enum prev() method
        begin
            static color_t c = GREEN;
            static color_t prev_val = c.prev();
            if (prev_val == RED) begin
                $display("  [PASS] Enum prev() returns RED before GREEN");
                passed++;
            end else begin
                $display("  [FAIL] Enum prev() should return RED before GREEN");
                failed++;
            end
        end

        // Test 7: Explicit enum values
        begin
            static state_t s = RUN;
            static int v = int'(s);
            if (v == 5) begin
                $display("  [PASS] Explicit enum value RUN=5");
                passed++;
            end else begin
                $display("  [FAIL] RUN should have value 5, got %0d", v);
                failed++;
            end
        end

        // Test 8: Enum comparison
        begin
            static color_t a = RED;
            static color_t b = BLUE;
            if (a < b) begin
                $display("  [PASS] Enum comparison RED < BLUE");
                passed++;
            end else begin
                $display("  [FAIL] RED should be less than BLUE");
                failed++;
            end
        end

        // Test 9: Enum num() method
        begin
            static color_t c = RED;
            static int count = c.num();
            if (count == 3) begin
                $display("  [PASS] Enum num() returns 3 members");
                passed++;
            end else begin
                $display("  [FAIL] Enum should have 3 members, got %0d", count);
                failed++;
            end
        end

        // Test 10: Enum with logic base type
        begin
            static sparse_t s = C;
            static logic [3:0] val = s;
            if (val == 4'b0111) begin
                $display("  [PASS] Sparse enum C=7 (4'b0111)");
                passed++;
            end else begin
                $display("  [FAIL] Sparse enum C should be 7");
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
