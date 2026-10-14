/*
:name: test_bits_size
:description: Test for $bits and $size
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 20.7 20.8.1 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_size.expected
*/
// Test for $bits and $size
// Covers size-related system functions
// IEEE 1800-2023 §20.6

module test_bits_size;
    logic [7:0] byte_val;
    logic [31:0] word_val;
    int arr[10];
    int dyn[];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: $bits of byte
        test_count++;
        if ($bits(byte_val) == 8) begin
            $display("Test 1: $bits(byte) PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: $bits of word
        test_count++;
        if ($bits(word_val) == 32) begin
            $display("Test 2: $bits(word) PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: $size of array
        test_count++;
        if ($size(arr) == 10) begin
            $display("Test 3: $size(array) PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: $size of dynamic array
        test_count++;
        dyn = new[5];
        if ($size(dyn) == 5) begin
            $display("Test 4: $size(dyn) PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: $clog2
        test_count++;
        if ($clog2(16) == 4) begin
            $display("Test 5: $clog2(16) PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: $countones
        test_count++;
        byte_val = 8'b10101010;
        if ($countones(byte_val) == 4) begin
            $display("Test 6: $countones PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
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
