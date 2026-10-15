/*
:name: test_enum_non_sequential
:description: Enum methods on an enum whose values are not consecutive
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_non_sequential.expected
*/
// Enum methods on an enum whose values are not consecutive
module test_enum_non_sequential;
    // Enum with gaps in values
    typedef enum int {
        LOW = 10,
        MEDIUM = 50,
        HIGH = 100
    } level_t;

    level_t level;

    initial begin
        static int passed = 0;
        static int failed = 0;

        $display("========== Non-Sequential Enum Test ==========");

        // Test 1: first() should return LOW (10)
        level = level.first();
        if (level == LOW && level == 10) begin
            $display("PASS: level.first() = LOW (10)");
            passed++;
        end else begin
            $display("FAIL: level.first() expected LOW (10), got %0d", level);
            failed++;
        end

        // Test 2: last() should return HIGH (100)
        level = level.last();
        if (level == HIGH && level == 100) begin
            $display("PASS: level.last() = HIGH (100)");
            passed++;
        end else begin
            $display("FAIL: level.last() expected HIGH (100), got %0d", level);
            failed++;
        end

        // Test 3: num() should return 3
        if (level.num() == 3) begin
            $display("PASS: level.num() = 3");
            passed++;
        end else begin
            $display("FAIL: level.num() expected 3, got %0d", level.num());
            failed++;
        end

        // Test 4: next() from LOW should give MEDIUM
        level = LOW;
        level = level.next();
        if (level == MEDIUM && level == 50) begin
            $display("PASS: LOW.next() = MEDIUM (50)");
            passed++;
        end else begin
            $display("FAIL: LOW.next() expected MEDIUM (50), got %0d", level);
            failed++;
        end

        // Test 5: prev() from HIGH should give MEDIUM
        level = HIGH;
        level = level.prev();
        if (level == MEDIUM && level == 50) begin
            $display("PASS: HIGH.prev() = MEDIUM (50)");
            passed++;
        end else begin
            $display("FAIL: HIGH.prev() expected MEDIUM (50), got %0d", level);
            failed++;
        end

        // Test 6: name() for each value
        level = LOW;
        if (level.name() == "LOW") begin
            $display("PASS: LOW.name() = \"LOW\"");
            passed++;
        end else begin
            $display("FAIL: LOW.name() expected \"LOW\", got \"%s\"", level.name());
            failed++;
        end

        level = MEDIUM;
        if (level.name() == "MEDIUM") begin
            $display("PASS: MEDIUM.name() = \"MEDIUM\"");
            passed++;
        end else begin
            $display("FAIL: MEDIUM.name() expected \"MEDIUM\", got \"%s\"", level.name());
            failed++;
        end

        level = HIGH;
        if (level.name() == "HIGH") begin
            $display("PASS: HIGH.name() = \"HIGH\"");
            passed++;
        end else begin
            $display("FAIL: HIGH.name() expected \"HIGH\", got \"%s\"", level.name());
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
