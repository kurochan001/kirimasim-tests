/*
:name: test_typedef_edge_cases
:description: typedef of vectors, int and a packed struct
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_edge_cases.expected
*/
// IEEE 1800-2023 §6.18: Typedef edge cases
// Tests for typedef declarations

module test_typedef_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;
    typedef int my_int;
    typedef struct packed { logic [3:0] a, b; } pair_t;

    byte_t b1, b2;
    word_t w;
    dword_t d;
    my_int mi;
    pair_t p;

    initial begin
        // Test 1: Byte typedef
        test_count++;
        b1 = 8'hAA;
        if (b1 == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: byte_t = %h", b1);
        end else begin
            $display("Test 1 FAIL: Byte unexpected = %h", b1);
        end

        // Test 2: Word typedef
        test_count++;
        w = 16'h1234;
        if (w == 16'h1234) begin
            pass_count++;
            $display("Test 2 PASS: word_t = %h", w);
        end else begin
            $display("Test 2 FAIL: Word unexpected = %h", w);
        end

        // Test 3: Dword typedef
        test_count++;
        d = 32'hDEADBEEF;
        if (d == 32'hDEADBEEF) begin
            pass_count++;
            $display("Test 3 PASS: dword_t = %h", d);
        end else begin
            $display("Test 3 FAIL: Dword unexpected = %h", d);
        end

        // Test 4: Int typedef
        test_count++;
        mi = 42;
        if (mi == 42) begin
            pass_count++;
            $display("Test 4 PASS: my_int = %0d", mi);
        end else begin
            $display("Test 4 FAIL: Int unexpected = %0d", mi);
        end

        // Test 5: Struct typedef
        test_count++;
        p.a = 4'hC;
        p.b = 4'hD;
        if (p.a == 4'hC && p.b == 4'hD) begin
            pass_count++;
            $display("Test 5 PASS: pair_t a=%h b=%h", p.a, p.b);
        end else begin
            $display("Test 5 FAIL: Struct unexpected");
        end

        // Test 6: Typedef assignment
        test_count++;
        b2 = b1;
        if (b2 == b1) begin
            pass_count++;
            $display("Test 6 PASS: Assign b2 = %h", b2);
        end else begin
            $display("Test 6 FAIL: Assign unexpected");
        end

        // Test 7: Arithmetic
        test_count++;
        b1 = 8'h10;
        b2 = 8'h05;
        begin
            static byte_t sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = b1 + b2;
            if (sum == 8'h15) begin
                pass_count++;
                $display("Test 7 PASS: Sum = %h", sum);
            end else begin
                $display("Test 7 FAIL: Sum unexpected = %h", sum);
            end
        end

        // Test 8: Bit select
        test_count++;
        w = 16'hFFFF;
        if (w[7:0] == 8'hFF) begin
            pass_count++;
            $display("Test 8 PASS: Bit select = %h", w[7:0]);
        end else begin
            $display("Test 8 FAIL: Sel unexpected");
        end

        // Test 9: Concatenation
        test_count++;
        begin
            static dword_t cat;
            // Assigned here so the result does not depend on the order of static initializers.
            cat = {w, w};
            if (cat == 32'hFFFFFFFF) begin
                pass_count++;
                $display("Test 9 PASS: Concat = %h", cat);
            end else begin
                $display("Test 9 FAIL: Concat unexpected");
            end
        end

        // Test 10: Packed struct as bits
        test_count++;
        begin
            static logic [7:0] bits;
            // Assigned here so the result does not depend on the order of static initializers.
            bits = p;
            if (bits == 8'hCD) begin
                pass_count++;
                $display("Test 10 PASS: Struct bits = %h", bits);
            end else begin
                $display("Test 10 FAIL: Bits unexpected = %h", bits);
            end
        end

        $display("=== Typedef Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
