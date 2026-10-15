/*
:name: test_concatenation_replication_2
:description: Concatenation and replication, including a concatenation on the left-hand side
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concatenation_replication_2.expected
*/
// Concatenation and replication, including a concatenation on the left-hand side
`timescale 1ns/1ps

module test_concatenation_replication;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Basic concatenation
    task test_basic_concat();
        static logic [3:0] a = 4'hA;
        static logic [3:0] b = 4'hB;
        logic [7:0] result;

        result = {a, b};

        if (result == 8'hAB) begin
            $display("PASS: Basic concatenation works");
            pass_count++;
        end else begin
            $display("FAIL: Basic concatenation failed (result: %h)", result);
            fail_count++;
        end
    endtask

    // Test 2: Multi-operand concatenation
    task test_multi_concat();
        static logic [3:0] a = 4'h1;
        static logic [3:0] b = 4'h2;
        static logic [3:0] c = 4'h3;
        static logic [3:0] d = 4'h4;
        logic [15:0] result;

        result = {a, b, c, d};

        if (result == 16'h1234) begin
            $display("PASS: Multi-operand concatenation works");
            pass_count++;
        end else begin
            $display("FAIL: Multi-operand concatenation failed");
            fail_count++;
        end
    endtask

    // Test 3: Concatenation with different widths
    task test_mixed_width_concat();
        static logic [7:0] byte_val = 8'hFF;
        static logic [3:0] nibble = 4'h5;
        static logic bit_val = 1'b1;
        logic [12:0] result;

        result = {byte_val, nibble, bit_val};

        if (result == 13'b11111111_0101_1) begin
            $display("PASS: Mixed width concatenation works");
            pass_count++;
        end else begin
            $display("FAIL: Mixed width result: %b", result);
            fail_count++;
        end
    endtask

    // Test 4: Basic replication
    task test_basic_replication();
        static logic [3:0] pattern = 4'hA;
        logic [15:0] result;

        result = {4{pattern}};

        if (result == 16'hAAAA) begin
            $display("PASS: Basic replication works");
            pass_count++;
        end else begin
            $display("FAIL: Basic replication failed (result: %h)", result);
            fail_count++;
        end
    endtask

    // Test 5: Replication of single bit
    task test_single_bit_replication();
        static logic bit_val = 1'b1;
        logic [7:0] result;

        result = {8{bit_val}};

        if (result == 8'hFF) begin
            $display("PASS: Single bit replication works");
            pass_count++;
        end else begin
            $display("FAIL: Single bit replication failed");
            fail_count++;
        end
    endtask

    // Test 6: Nested replication
    task test_nested_replication();
        static logic [1:0] bits = 2'b10;
        logic [7:0] result;

        result = {2{{2{bits}}}};

        if (result == 8'b10101010) begin
            $display("PASS: Nested replication works");
            pass_count++;
        end else begin
            $display("FAIL: Nested replication result: %b", result);
            fail_count++;
        end
    endtask

    // Test 7: Replication in concatenation
    task test_repl_in_concat();
        static logic [3:0] a = 4'hA;
        static logic [3:0] b = 4'hB;
        logic [15:0] result;

        result = {{2{a}}, {2{b}}};

        if (result == 16'hAABB) begin
            $display("PASS: Replication in concatenation works");
            pass_count++;
        end else begin
            $display("FAIL: Replication in concatenation failed");
            fail_count++;
        end
    endtask

    // Test 8: Sign extension using replication
    task test_sign_extension();
        static logic [7:0] val = 8'b10000001;  // -127 in signed
        logic [15:0] sign_extended;

        sign_extended = {{8{val[7]}}, val};

        if (sign_extended == 16'hFF81) begin
            $display("PASS: Sign extension using replication works");
            pass_count++;
        end else begin
            $display("FAIL: Sign extension failed (result: %h)", sign_extended);
            fail_count++;
        end
    endtask

    // Test 9: Zero extension using concatenation
    task test_zero_extension();
        static logic [7:0] val = 8'hAB;
        logic [15:0] zero_extended;

        zero_extended = {8'b0, val};

        if (zero_extended == 16'h00AB) begin
            $display("PASS: Zero extension works");
            pass_count++;
        end else begin
            $display("FAIL: Zero extension failed");
            fail_count++;
        end
    endtask

    // Test 10: Concatenation assignment
    task test_concat_assignment();
        logic [3:0] upper;
        logic [3:0] lower;
        static logic [7:0] val = 8'hCD;

        {upper, lower} = val;

        if (upper == 4'hC && lower == 4'hD) begin
            $display("PASS: Concatenation assignment works");
            pass_count++;
        end else begin
            $display("FAIL: Concatenation assignment failed");
            fail_count++;
        end
    endtask

    // Test 11: Replication count 1
    task test_replication_one();
        static logic [7:0] val = 8'hAB;
        logic [7:0] result;

        result = {1{val}};

        if (result == 8'hAB) begin
            $display("PASS: Replication count 1 works");
            pass_count++;
        end else begin
            $display("FAIL: Replication count 1 failed");
            fail_count++;
        end
    endtask

    // Test 12: Empty concatenation parts
    task test_literal_concat();
        logic [15:0] result;

        result = {8'hDE, 8'hAD};

        if (result == 16'hDEAD) begin
            $display("PASS: Literal concatenation works");
            pass_count++;
        end else begin
            $display("FAIL: Literal concatenation failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Concatenation and Replication Test ===");

        test_basic_concat();
        test_multi_concat();
        test_mixed_width_concat();
        test_basic_replication();
        test_single_bit_replication();
        test_nested_replication();
        test_repl_in_concat();
        test_sign_extension();
        test_zero_extension();
        test_concat_assignment();
        test_replication_one();
        test_literal_concat();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
