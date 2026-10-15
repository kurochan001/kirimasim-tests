/*
:name: test_typedef_types_edge_cases
:description: typedef of vectors, packed arrays and int unsigned, with casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_types_edge_cases.expected
*/
// typedef of vectors, packed arrays and int unsigned, with casts
// IEEE 1800-2023 Section 6.18 User-Defined Types
// Tests corner cases: typedef declarations

`timescale 1ns/1ps

module test_typedef_types_edge_cases;
    int passed = 0;
    int failed = 0;

    // Various typedef declarations
    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;
    typedef int unsigned uint_t;
    typedef bit [3:0] nibble_t;
    typedef byte_t [3:0] bytes4_t;

    byte_t b;
    word_t w;
    dword_t d;
    uint_t u;
    nibble_t n;
    bytes4_t b4;

    initial begin
        $display("TEST: Typedef types edge cases");

        // Test 1: Basic typedef
        begin
            b = 8'hAB;
            if (b == 8'hAB) begin
                $display("  [PASS] Basic typedef");
                passed++;
            end else begin
                $display("  [FAIL] Basic: %h", b);
                failed++;
            end
        end

        // Test 2: Word typedef
        begin
            w = 16'h1234;
            if (w == 16'h1234) begin
                $display("  [PASS] Word typedef");
                passed++;
            end else begin
                $display("  [FAIL] Word: %h", w);
                failed++;
            end
        end

        // Test 3: Dword typedef
        begin
            d = 32'hDEADBEEF;
            if (d == 32'hDEADBEEF) begin
                $display("  [PASS] Dword typedef");
                passed++;
            end else begin
                $display("  [FAIL] Dword: %h", d);
                failed++;
            end
        end

        // Test 4: Unsigned typedef
        begin
            u = 100;
            if (u == 100) begin
                $display("  [PASS] Unsigned typedef");
                passed++;
            end else begin
                $display("  [FAIL] Unsigned: %0d", u);
                failed++;
            end
        end

        // Test 5: Nibble typedef
        begin
            n = 4'hF;
            if (n == 4'hF) begin
                $display("  [PASS] Nibble typedef");
                passed++;
            end else begin
                $display("  [FAIL] Nibble: %h", n);
                failed++;
            end
        end

        // Test 6: Typedef array
        begin
            b4[0] = 8'hAA;
            b4[1] = 8'hBB;
            b4[2] = 8'hCC;
            b4[3] = 8'hDD;
            if (b4[0] == 8'hAA && b4[3] == 8'hDD) begin
                $display("  [PASS] Typedef array");
                passed++;
            end else begin
                $display("  [FAIL] Array: %h %h", b4[0], b4[3]);
                failed++;
            end
        end

        // Test 7: Typedef bits
        begin
            if ($bits(byte_t) == 8 && $bits(word_t) == 16) begin
                $display("  [PASS] Typedef bits");
                passed++;
            end else begin
                $display("  [FAIL] Bits: %0d %0d", $bits(byte_t), $bits(word_t));
                failed++;
            end
        end

        // Test 8: Typedef arithmetic
        begin
            byte_t a, c;
            a = 8'd10;
            b = 8'd20;
            c = a + b;
            if (c == 30) begin
                $display("  [PASS] Typedef arithmetic");
                passed++;
            end else begin
                $display("  [FAIL] Arith: %0d", c);
                failed++;
            end
        end

        // Test 9: Typedef cast
        begin
            static int i = 255;
            b = byte_t'(i);
            if (b == 8'hFF) begin
                $display("  [PASS] Typedef cast");
                passed++;
            end else begin
                $display("  [FAIL] Cast: %h", b);
                failed++;
            end
        end

        // Test 10: Typedef compare
        begin
            byte_t x, y;
            x = 8'h55;
            y = 8'h55;
            if (x == y) begin
                $display("  [PASS] Typedef compare");
                passed++;
            end else begin
                $display("  [FAIL] Compare failed");
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
