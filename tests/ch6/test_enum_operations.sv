/*
:name: test_enum_operations
:description: Enum Operations Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_operations.expected
*/
// IEEE 1800-2023 Section 6.19 - Enum Operations Tests
// Tests: Enum values, methods, iteration

module test_enum_operations;
    int pass_count = 0;
    int fail_count = 0;

    typedef enum logic [2:0] {
        RED   = 3'd0,
        GREEN = 3'd1,
        BLUE  = 3'd2,
        WHITE = 3'd7
    } color_t;

    typedef enum int {
        IDLE  = 0,
        RUN   = 1,
        PAUSE = 2,
        STOP  = 3
    } state_t;

    color_t c1, c2;
    state_t s1;
    int idx;

    initial begin
        $display("=== IEEE 1800-2023 Enum Operations Tests ===");

        // Test 1: Enum assignment
        $display("Test 1: Enum assignment");
        c1 = RED;
        if (c1 == RED) begin
            $display("Test 1 PASS: c1=RED");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Enum value
        $display("Test 2: Enum value");
        if (c1 == 3'd0) begin
            $display("Test 2 PASS: RED == 0");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Enum comparison
        $display("Test 3: Enum comparison");
        c1 = GREEN;
        c2 = BLUE;
        if (c1 != c2) begin
            $display("Test 3 PASS: GREEN != BLUE");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Enum as index
        $display("Test 4: Enum as index");
        c1 = GREEN;
        idx = int'(c1);
        if (idx == 1) begin
            $display("Test 4 PASS: GREEN index = %0d", idx);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Non-sequential enum
        $display("Test 5: Non-sequential enum");
        c1 = WHITE;
        if (c1 == 3'd7) begin
            $display("Test 5 PASS: WHITE == 7");
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: State enum
        $display("Test 6: State enum");
        s1 = RUN;
        if (s1 == RUN && s1 == 1) begin
            $display("Test 6 PASS: s1=RUN=%0d", s1);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Enum in case
        $display("Test 7: Enum in case");
        c1 = BLUE;
        case (c1)
            RED:   idx = 10;
            GREEN: idx = 20;
            BLUE:  idx = 30;
            WHITE: idx = 40;
        endcase
        if (idx == 30) begin
            $display("Test 7 PASS: BLUE case matched");
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Assign different enum value
        $display("Test 8: Assign different value");
        c1 = RED;
        c1 = GREEN;
        c1 = BLUE;
        if (c1 == BLUE) begin
            $display("Test 8 PASS: final c1=BLUE");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
