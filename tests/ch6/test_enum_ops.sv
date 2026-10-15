/*
:name: test_enum_ops
:description: Test for enum operations
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_ops.expected
*/
// Test for enum operations
// IEEE 1800-2023 §6.19 and §6.19.5

module test_enum_ops;
    typedef enum {IDLE, RUN, PAUSE, STOP} state_e;
    typedef enum logic [2:0] {A=1, B=2, C=4} code_e;

    state_e st;
    code_e cd;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Enum assignment
        test_count++;
        st = IDLE;
        if (st == IDLE) begin
            $display("Test 1: Enum assignment PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Enum comparison
        test_count++;
        st = RUN;
        if (st != IDLE) begin
            $display("Test 2: Enum comparison PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Enum next/prev
        test_count++;
        st = st.next();
        if (st == PAUSE) begin
            $display("Test 3: Enum next PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Enum with explicit values
        test_count++;
        cd = B;
        if (cd == 2) begin
            $display("Test 4: Enum explicit value PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Enum first/last
        test_count++;
        st = st.first();
        if (st == IDLE) begin
            $display("Test 5: Enum first PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
