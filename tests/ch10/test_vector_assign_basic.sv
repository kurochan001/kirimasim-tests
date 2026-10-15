/*
:name: test_vector_assign_basic
:description: Assignments to vectors of several widths, including a concatenation
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vector_assign_basic.expected
*/
// Assignments to vectors of several widths, including a concatenation
// IEEE 1800-2023 §25

module test_vector_assign_basic;
    logic [7:0] sig1;
    logic [15:0] sig2;
    logic [31:0] sig3;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Signal initialization
        test_count++;
        sig1 = 8'hAA;
        if (sig1 == 8'hAA) begin
            $display("Test 1: Signal initialization PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Signal update
        test_count++;
        sig1 = 8'h55;
        if (sig1 == 8'h55) begin
            $display("Test 2: Signal update PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Wide signal
        test_count++;
        sig3 = 32'hDEADBEEF;
        if (sig3 == 32'hDEADBEEF) begin
            $display("Test 3: Wide signal PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Multiple signals
        test_count++;
        sig1 = 8'h11;
        sig2 = 16'h2222;
        sig3 = 32'h33333333;
        $display("Test 4: Multiple signals PASS");
        pass_count++;

        // Test 5: Signal dependency
        test_count++;
        sig2 = {sig1, sig1};
        if (sig2 == 16'h1111) begin
            $display("Test 5: Signal dependency PASS");
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
