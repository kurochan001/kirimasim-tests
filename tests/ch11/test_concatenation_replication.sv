/*
:name: test_concatenation_replication
:description: Concatenation and replication, nested forms and a concatenation on the left-hand side
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concatenation_replication.expected
*/
// IEEE 1800-2023 §11.4.12: Concatenation and replication edge cases
// Tests for {}, {n{}} operators

module test_concatenation_replication;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b;
    logic [15:0] wide;
    logic [31:0] result32;

    initial begin
        // Test 1: Basic concatenation
        test_count++;
        a = 8'hAB;
        b = 8'hCD;
        wide = {a, b};
        if (wide == 16'hABCD) begin
            pass_count++;
            $display("Test 1 PASS: {AB,CD} = %h", wide);
        end else begin
            $display("Test 1 FAIL: result = %h", wide);
        end

        // Test 2: Triple concatenation
        test_count++;
        begin
            static logic [23:0] triple = {8'h11, 8'h22, 8'h33};
            if (triple == 24'h112233) begin
                pass_count++;
                $display("Test 2 PASS: Triple concat = %h", triple);
            end else begin
                $display("Test 2 FAIL: result = %h", triple);
            end
        end

        // Test 3: Single bit concatenation
        test_count++;
        begin
            static logic [3:0] bits = {1'b1, 1'b0, 1'b1, 1'b1};
            if (bits == 4'b1011) begin
                pass_count++;
                $display("Test 3 PASS: Bit concat = %b", bits);
            end else begin
                $display("Test 3 FAIL: result = %b", bits);
            end
        end

        // Test 4: Replication x2
        test_count++;
        a = 8'hAB;
        wide = {2{a}};
        if (wide == 16'hABAB) begin
            pass_count++;
            $display("Test 4 PASS: {2{AB}} = %h", wide);
        end else begin
            $display("Test 4 FAIL: result = %h", wide);
        end

        // Test 5: Replication x4
        test_count++;
        begin
            static logic [3:0] nibble = 4'hF;
            wide = {4{nibble}};
            if (wide == 16'hFFFF) begin
                pass_count++;
                $display("Test 5 PASS: {4{F}} = %h", wide);
            end else begin
                $display("Test 5 FAIL: result = %h", wide);
            end
        end

        // Test 6: Single bit replication
        test_count++;
        begin
            static logic [7:0] ones = {8{1'b1}};
            if (ones == 8'hFF) begin
                pass_count++;
                $display("Test 6 PASS: {8{1}} = %h", ones);
            end else begin
                $display("Test 6 FAIL: result = %h", ones);
            end
        end

        // Test 7: Zero replication
        test_count++;
        begin
            static logic [7:0] zeros = {8{1'b0}};
            if (zeros == 8'h00) begin
                pass_count++;
                $display("Test 7 PASS: {8{0}} = %h", zeros);
            end else begin
                $display("Test 7 FAIL: result = %h", zeros);
            end
        end

        // Test 8: Nested replication
        test_count++;
        begin
            static logic [7:0] nested = {2{{2{2'b10}}}};
            if (nested == 8'b10101010) begin
                pass_count++;
                $display("Test 8 PASS: Nested replication = %b", nested);
            end else begin
                $display("Test 8 FAIL: result = %b", nested);
            end
        end

        // Test 9: Concat with zero extension
        test_count++;
        begin
            static logic [3:0] small_val = 4'h5;
            static logic [7:0] extended;
            // Assigned here so the result does not depend on the order of static initializers.
            extended = {4'b0000, small_val};
            if (extended == 8'h05) begin
                pass_count++;
                $display("Test 9 PASS: Zero extension = %h", extended);
            end else begin
                $display("Test 9 FAIL: result = %h", extended);
            end
        end

        // Test 10: Concat with sign extension (via replication)
        test_count++;
        begin
            static logic [3:0] signed_val = 4'b1001;  // -7 as 4-bit signed
            static logic [7:0] sign_ext;
            // Assigned here so the result does not depend on the order of static initializers.
            sign_ext = {{4{signed_val[3]}}, signed_val};
            if (sign_ext == 8'b11111001) begin
                pass_count++;
                $display("Test 10 PASS: Sign extension = %b", sign_ext);
            end else begin
                $display("Test 10 FAIL: result = %b", sign_ext);
            end
        end

        // Test 11: Empty string in concat (via empty)
        test_count++;
        a = 8'hFF;
        b = 8'h00;
        wide = {a, b};
        if (wide == 16'hFF00) begin
            pass_count++;
            $display("Test 11 PASS: {FF,00} = %h", wide);
        end else begin
            $display("Test 11 FAIL: result = %h", wide);
        end

        // Test 12: Large replication
        test_count++;
        result32 = {32{1'b1}};
        if (result32 == 32'hFFFFFFFF) begin
            pass_count++;
            $display("Test 12 PASS: {32{1}} = %h", result32);
        end else begin
            $display("Test 12 FAIL: result = %h", result32);
        end

        // Test 13: Mixed size concat
        test_count++;
        begin
            static logic [11:0] mixed = {4'hA, 8'hBC};
            if (mixed == 12'hABC) begin
                pass_count++;
                $display("Test 13 PASS: {4,8} = %h", mixed);
            end else begin
                $display("Test 13 FAIL: result = %h", mixed);
            end
        end

        // Test 14: Concat in assignment
        test_count++;
        begin
            logic [3:0] hi, lo;
            {hi, lo} = 8'hAB;
            if (hi == 4'hA && lo == 4'hB) begin
                pass_count++;
                $display("Test 14 PASS: LHS concat hi=%h lo=%h", hi, lo);
            end else begin
                $display("Test 14 FAIL: LHS concat wrong hi=%h lo=%h", hi, lo);
            end
        end

        // Test 15: Replication of concat
        test_count++;
        begin
            static logic [7:0] rep_cat = {2{{2'b10, 2'b01}}};
            if (rep_cat == 8'b10011001) begin
                pass_count++;
                $display("Test 15 PASS: {2{{10,01}}} = %b", rep_cat);
            end else begin
                $display("Test 15 FAIL: result = %b", rep_cat);
            end
        end

        // Test 16: Concat of replication
        test_count++;
        begin
            static logic [7:0] cat_rep = {{2{2'b11}}, {2{2'b00}}};
            if (cat_rep == 8'b11110000) begin
                pass_count++;
                $display("Test 16 PASS: {{2{11}},{2{00}}} = %b", cat_rep);
            end else begin
                $display("Test 16 FAIL: result = %b", cat_rep);
            end
        end

        // Test 17: Variable in replication value
        test_count++;
        a = 8'hAA;
        result32 = {4{a}};
        if (result32 == 32'hAAAAAAAA) begin
            pass_count++;
            $display("Test 17 PASS: {4{var}} = %h", result32);
        end else begin
            $display("Test 17 FAIL: result = %h", result32);
        end

        // Test 18: Single element concat
        test_count++;
        a = 8'h55;
        b = {a};
        if (b == 8'h55) begin
            pass_count++;
            $display("Test 18 PASS: Single elem concat = %h", b);
        end else begin
            $display("Test 18 FAIL: result = %h", b);
        end

        // Test 19: Concat with literal
        test_count++;
        a = 8'h0F;
        wide = {a, 8'hF0};
        if (wide == 16'h0FF0) begin
            pass_count++;
            $display("Test 19 PASS: {var,literal} = %h", wide);
        end else begin
            $display("Test 19 FAIL: result = %h", wide);
        end

        // Test 20: Alternating pattern
        test_count++;
        begin
            static logic [7:0] alt = {4{2'b10}};
            if (alt == 8'b10101010) begin
                pass_count++;
                $display("Test 20 PASS: Alternating = %b", alt);
            end else begin
                $display("Test 20 FAIL: result = %b", alt);
            end
        end

        $display("=== Concatenation/Replication Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
