/*
:name: test_system_functions_advanced
:description: Advanced System Functions Tests
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 20.8.1 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_functions_advanced.expected
*/
// IEEE 1800-2023 Section 20 - Advanced System Functions Tests
// Tests: $bits, $typename, $countones, $onehot, $clog2

module test_system_functions_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Various types for testing
    logic [7:0] l8;
    logic [15:0] l16;
    logic [31:0] l32;
    int i;
    byte b;
    shortint si;
    longint li;

    // Struct for $bits test
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [7:0] c;
    } struct24_t;

    struct24_t s24;

    initial begin
        $display("=== IEEE 1800-2023 Advanced System Functions Tests ===");

        // Test 1: $bits on basic types
        $display("Test 1: $bits on basic types");
        if ($bits(l8) == 8 && $bits(l16) == 16 && $bits(l32) == 32) begin
            $display("Test 1 PASS: $bits(l8)=%0d, $bits(l16)=%0d, $bits(l32)=%0d",
                     $bits(l8), $bits(l16), $bits(l32));
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: $bits on struct
        $display("Test 2: $bits on struct");
        if ($bits(s24) == 24) begin
            $display("Test 2 PASS: $bits(struct24_t)=%0d", $bits(s24));
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", $bits(s24));
            fail_count++;
        end

        // Test 3: $countones
        $display("Test 3: $countones");
        l8 = 8'b10101010;  // 4 ones
        if ($countones(l8) == 4) begin
            $display("Test 3 PASS: $countones(8'b10101010)=%0d", $countones(l8));
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", $countones(l8));
            fail_count++;
        end

        // Test 4: $countones with all ones
        $display("Test 4: $countones with all ones");
        l8 = 8'hFF;  // 8 ones
        if ($countones(l8) == 8) begin
            $display("Test 4 PASS: $countones(8'hFF)=%0d", $countones(l8));
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %0d", $countones(l8));
            fail_count++;
        end

        // Test 5: $onehot
        $display("Test 5: $onehot");
        l8 = 8'b00010000;  // exactly one bit set
        if ($onehot(l8) == 1) begin
            $display("Test 5 PASS: $onehot(8'b00010000)=%0d", $onehot(l8));
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %0d", $onehot(l8));
            fail_count++;
        end

        // Test 6: $onehot with multiple bits
        $display("Test 6: $onehot with multiple bits");
        l8 = 8'b00010001;  // two bits set
        if ($onehot(l8) == 0) begin
            $display("Test 6 PASS: $onehot(8'b00010001)=%0d", $onehot(l8));
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %0d", $onehot(l8));
            fail_count++;
        end

        // Test 7: $onehot0 (zero or one bit)
        $display("Test 7: $onehot0");
        l8 = 8'b00000000;  // zero bits set
        if ($onehot0(l8) == 1) begin
            $display("Test 7 PASS: $onehot0(8'b00000000)=%0d", $onehot0(l8));
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %0d", $onehot0(l8));
            fail_count++;
        end

        // Test 8: $clog2
        $display("Test 8: $clog2");
        if ($clog2(8) == 3 && $clog2(16) == 4 && $clog2(1) == 0) begin
            $display("Test 8 PASS: $clog2(8)=%0d, $clog2(16)=%0d, $clog2(1)=%0d",
                     $clog2(8), $clog2(16), $clog2(1));
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
