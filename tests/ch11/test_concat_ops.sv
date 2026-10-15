/*
:name: test_concat_ops
:description: Test for concatenation operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_ops.expected
*/
// Test for concatenation operations
// IEEE 1800-2023 §11.4.12

module test_concat_ops;
    logic [3:0] a, b;
    logic [7:0] result8;
    logic [15:0] result16;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple concatenation
        test_count++;
        a = 4'hA;
        b = 4'h5;
        result8 = {a, b};
        if (result8 == 8'hA5) begin
            $display("Test 1: Simple concatenation PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Replication
        test_count++;
        a = 4'h3;
        result8 = {2{a}};
        if (result8 == 8'h33) begin
            $display("Test 2: Replication PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Nested concatenation
        test_count++;
        result16 = {{2{a}}, {2{b}}};
        if (result16 == 16'h3355) begin
            $display("Test 3: Nested concatenation PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Mixed sizes
        test_count++;
        result8 = {4'hF, 4'h0};
        if (result8 == 8'hF0) begin
            $display("Test 4: Mixed sizes PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Single bit concat
        test_count++;
        result8 = {1'b1, 1'b0, 1'b1, 1'b0, 4'h0};
        if (result8 == 8'hA0) begin
            $display("Test 5: Single bit concat PASS");
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
