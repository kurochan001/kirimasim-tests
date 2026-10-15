/*
:name: test_type_casting_edge_cases
:description: Type casting edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_casting_edge_cases.expected
*/
// IEEE 1800-2023 §6.24: Type casting edge cases
// Tests for $cast, type', size cast, and explicit conversions

module test_type_casting_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    typedef enum {RED, GREEN, BLUE} color_e;

    initial begin
        // Test 1: int to shortint
        test_count++;
        begin
            static int i = 32'h00001234;
            static shortint s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = shortint'(i);
            if (s == 16'h1234) begin
                pass_count++;
                $display("Test 1 PASS: int to shortint = %h", s);
            end else begin
                $display("Test 1 FAIL: s = %h", s);
            end
        end

        // Test 2: int to byte
        test_count++;
        begin
            static int i = 32'h000000AB;
            static byte b;
            // Assigned here so the result does not depend on the order of static initializers.
            b = byte'(i);
            if (b == 8'hAB) begin
                pass_count++;
                $display("Test 2 PASS: int to byte = %h", b);
            end else begin
                $display("Test 2 FAIL: b = %h", b);
            end
        end

        // Test 3: Unsigned to signed
        test_count++;
        begin
            static logic [7:0] u = 8'hFF;
            static byte s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = byte'(u);
            if (s == -1) begin
                pass_count++;
                $display("Test 3 PASS: unsigned to signed = %0d", s);
            end else begin
                $display("Test 3 FAIL: unsigned to signed = %0d", s);
            end
        end

        // Test 4: Real to int
        test_count++;
        begin
            static real r = 3.7;
            static int i;
            // Assigned here so the result does not depend on the order of static initializers.
            i = int'(r);
            if (i == 4) begin  // Rounds to the nearest integer (6.12.1)
                pass_count++;
                $display("Test 4 PASS: real to int = %0d", i);
            end else begin
                $display("Test 4 FAIL: i = %0d", i);
            end
        end

        // Test 5: Int to real
        test_count++;
        begin
            static int i = 42;
            static real r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = real'(i);
            if (r >= 41.9 && r <= 42.1) begin
                pass_count++;
                $display("Test 5 PASS: int to real = %f", r);
            end else begin
                $display("Test 5 FAIL: r = %f", r);
            end
        end

        // Test 6: Size cast expand
        test_count++;
        begin
            static logic [7:0] small_val = 8'hAB;
            static logic [15:0] big;
            // Assigned here so the result does not depend on the order of static initializers.
            big = 16'(small_val);
            if (big == 16'h00AB) begin
                pass_count++;
                $display("Test 6 PASS: 8-bit to 16-bit = %h", big);
            end else begin
                $display("Test 6 FAIL: big = %h", big);
            end
        end

        // Test 7: Size cast truncate
        test_count++;
        begin
            static logic [15:0] big = 16'hABCD;
            static logic [7:0] small_val;
            // Assigned here so the result does not depend on the order of static initializers.
            small_val = 8'(big);
            if (small_val == 8'hCD) begin
                pass_count++;
                $display("Test 7 PASS: 16-bit to 8-bit = %h", small_val);
            end else begin
                $display("Test 7 FAIL: small_val = %h", small_val);
            end
        end

        // Test 8: Enum from int
        test_count++;
        begin
            static int i = 1;
            static color_e c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = color_e'(i);
            if (c == GREEN) begin
                pass_count++;
                $display("Test 8 PASS: int to enum = GREEN");
            end else begin
                $display("Test 8 FAIL: enum cast unexpected");
            end
        end

        // Test 9: Enum to int
        test_count++;
        begin
            static color_e c = BLUE;
            int i;
            i = int'(c);
            if (i == 2) begin
                pass_count++;
                $display("Test 9 PASS: enum to int = %0d", i);
            end else begin
                $display("Test 9 FAIL: i = %0d", i);
            end
        end

        // Test 10: String to int ($sscanf style test)
        test_count++;
        begin
            static string s = "123";
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = s.atoi();
            if (val == 123) begin
                pass_count++;
                $display("Test 10 PASS: string to int = %0d", val);
            end else begin
                $display("Test 10 FAIL: val = %0d", val);
            end
        end

        // Test 11: Signed size cast
        test_count++;
        begin
            static int signed si = -10;
            static logic signed [15:0] ss;
            // Assigned here so the result does not depend on the order of static initializers.
            ss = 16'(si);
            if ($signed(ss) == -10) begin
                pass_count++;
                $display("Test 11 PASS: signed size cast = %0d", $signed(ss));
            end else begin
                $display("Test 11 FAIL: signed cast unexpected = %0d", ss);
            end
        end

        // Test 12: Zero extend
        test_count++;
        begin
            static logic [3:0] nibble = 4'hF;
            static logic [7:0] extended;
            // Assigned here so the result does not depend on the order of static initializers.
            extended = 8'(nibble);
            if (extended == 8'h0F) begin
                pass_count++;
                $display("Test 12 PASS: Zero extend = %h", extended);
            end else begin
                $display("Test 12 FAIL: extended = %h", extended);
            end
        end

        // Test 13: Cast in expression
        test_count++;
        begin
            static logic [7:0] a = 8'h10;
            static logic [7:0] b = 8'h20;
            static int sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = int'(a) + int'(b);
            if (sum == 48) begin
                pass_count++;
                $display("Test 13 PASS: Cast in expr sum = %0d", sum);
            end else begin
                $display("Test 13 FAIL: sum = %0d", sum);
            end
        end

        // Test 14: Negative to unsigned
        test_count++;
        begin
            static int neg = -1;
            static logic [31:0] u;
            // Assigned here so the result does not depend on the order of static initializers.
            u = 32'(neg);
            if (u == 32'hFFFFFFFF) begin
                pass_count++;
                $display("Test 14 PASS: -1 to unsigned = %h", u);
            end else begin
                $display("Test 14 FAIL: u = %h", u);
            end
        end

        // Test 15: Double cast
        test_count++;
        begin
            static logic [31:0] wide = 32'h12345678;
            static logic [7:0] narrow;
            // Assigned here so the result does not depend on the order of static initializers.
            narrow = 8'(16'(wide));
            if (narrow == 8'h78) begin
                pass_count++;
                $display("Test 15 PASS: Double cast = %h", narrow);
            end else begin
                $display("Test 15 FAIL: narrow = %h", narrow);
            end
        end

        // Test 16: Cast to same size
        test_count++;
        begin
            static logic [7:0] a = 8'hAB;
            static logic [7:0] b;
            // Assigned here so the result does not depend on the order of static initializers.
            b = 8'(a);
            if (b == 8'hAB) begin
                pass_count++;
                $display("Test 16 PASS: Same size cast = %h", b);
            end else begin
                $display("Test 16 FAIL");
            end
        end

        // Test 17: Enum out of range
        test_count++;
        begin
            static int i = 10;  // Out of enum range
            static color_e c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = color_e'(i);
            // A cast to an enum type does not check the value (6.19.4)
            if (int'(c) == 10) begin
                pass_count++;
                $display("Test 17 PASS: Out of range enum cast keeps %0d", int'(c));
            end else begin
                $display("Test 17 FAIL: Out of range enum cast gave %0d", int'(c));
            end
        end

        // Test 18: Real precision
        test_count++;
        begin
            static real r = 1.5;
            static int i;
            // Assigned here so the result does not depend on the order of static initializers.
            i = int'(r);
            // 1.5 is rounded away from zero (6.12.1)
            if (i == 2) begin
                pass_count++;
                $display("Test 18 PASS: Real rounding = %0d", i);
            end else begin
                $display("Test 18 FAIL: i = %0d", i);
            end
        end

        // Test 19: Large value truncation
        test_count++;
        begin
            static logic [63:0] large_val = 64'hFFFFFFFF_12345678;
            static logic [31:0] trunc_val;
            // Assigned here so the result does not depend on the order of static initializers.
            trunc_val = 32'(large_val);
            if (trunc_val == 32'h12345678) begin
                pass_count++;
                $display("Test 19 PASS: Large truncation = %h", trunc_val);
            end else begin
                $display("Test 19 FAIL: trunc = %h", trunc_val);
            end
        end

        // Test 20: Type cast chain
        test_count++;
        begin
            static real r = 100.9;
            static byte b;
            // Assigned here so the result does not depend on the order of static initializers.
            b = byte'(int'(r));
            if (b == 101) begin
                pass_count++;
                $display("Test 20 PASS: Type cast chain = %0d", b);
            end else begin
                $display("Test 20 FAIL: b = %0d", b);
            end
        end

        $display("=== Type Casting Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
