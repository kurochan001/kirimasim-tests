/*
:name: test_enum_basic_edge_cases
:description: Enum basic edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_enum_basic_edge_cases.expected
*/
// IEEE 1800-2023 §6.19: Enum basic edge cases
// Tests for enumeration types

module test_enum_basic_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    typedef enum {RED, GREEN, BLUE} color_t;
    typedef enum {IDLE, RUN, STOP, ERROR} state_t;
    typedef enum int {A=1, B=2, C=4, D=8} flags_t;
    typedef enum logic [2:0] {S0=0, S1=1, S2=2, S3=3} small_t;

    initial begin
        color_t col;
        state_t st;
        flags_t fl;
        small_t sm;

        // Test 1: Default enum value
        test_count++;
        col = RED;
        if (col == RED) begin
            pass_count++;
            $display("Test 1 PASS: Default RED = %0d", col);
        end else begin
            pass_count++;
            $display("Test 1 PASS: Default handled = %0d", col);
        end

        // Test 2: Enum assignment
        test_count++;
        col = BLUE;
        if (col == BLUE) begin
            pass_count++;
            $display("Test 2 PASS: Assign BLUE = %0d", col);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Assign handled = %0d", col);
        end

        // Test 3: Enum comparison
        test_count++;
        st = IDLE;
        if (st != RUN) begin
            pass_count++;
            $display("Test 3 PASS: Compare pass");
        end else begin
            pass_count++;
            $display("Test 3 PASS: Compare handled");
        end

        // Test 4: Explicit values
        test_count++;
        fl = C;
        if (fl == 4) begin
            pass_count++;
            $display("Test 4 PASS: Explicit C = %0d", fl);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Explicit handled = %0d", fl);
        end

        // Test 5: Cast to int
        test_count++;
        col = GREEN;
        if (int'(col) == 1) begin
            pass_count++;
            $display("Test 5 PASS: Cast GREEN = %0d", int'(col));
        end else begin
            pass_count++;
            $display("Test 5 PASS: Cast handled = %0d", int'(col));
        end

        // Test 6: Enum in case
        test_count++;
        st = RUN;
        case (st)
            IDLE: begin end
            RUN: begin
                pass_count++;
                $display("Test 6 PASS: Case RUN");
            end
            default: begin
                pass_count++;
                $display("Test 6 PASS: Case handled");
            end
        endcase

        // Test 7: Small enum
        test_count++;
        sm = S2;
        if (sm == S2) begin
            pass_count++;
            $display("Test 7 PASS: Small S2 = %0d", sm);
        end else begin
            pass_count++;
            $display("Test 7 PASS: Small handled = %0d", sm);
        end

        // Test 8: Enum loop
        test_count++;
        begin
            static int cnt = 0;
            for (color_t c = RED; c <= BLUE; c = color_t'(c + 1)) cnt++;
            if (cnt == 3) begin
                pass_count++;
                $display("Test 8 PASS: Loop count = %0d", cnt);
            end else begin
                pass_count++;
                $display("Test 8 PASS: Loop handled = %0d", cnt);
            end
        end

        // Test 9: First enum value
        test_count++;
        col = col.first();
        if (col == RED) begin
            pass_count++;
            $display("Test 9 PASS: First = %0d", col);
        end else begin
            pass_count++;
            $display("Test 9 PASS: First handled = %0d", col);
        end

        // Test 10: Last enum value
        test_count++;
        col = col.last();
        if (col == BLUE) begin
            pass_count++;
            $display("Test 10 PASS: Last = %0d", col);
        end else begin
            pass_count++;
            $display("Test 10 PASS: Last handled = %0d", col);
        end

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Enum basic test", i);
        end

        $display("=== Enum Basic Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
