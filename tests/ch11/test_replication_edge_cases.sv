/*
:name: test_replication_edge_cases
:description: Replication of constants, variables and expressions, nested and in concatenations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_replication_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.12.1: Replication operator edge cases
// Tests for {{N{}}} replication

module test_replication_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [31:0] wide;
    logic [63:0] bigger;
    logic [7:0] byte_val;

    initial begin
        // Test 1: Basic replication
        test_count++;
        byte_val = 8'hAB;
        wide = {4{byte_val}};
        if (wide == 32'hABABABAB) begin
            pass_count++;
            $display("Test 1 PASS: {4{8'hAB}} = %h", wide);
        end else begin
            $display("Test 1 FAIL: Repl unexpected = %h", wide);
        end

        // Test 2: Single bit replication
        test_count++;
        wide = {32{1'b1}};
        if (wide == 32'hFFFFFFFF) begin
            pass_count++;
            $display("Test 2 PASS: {32{1'b1}} = %h", wide);
        end else begin
            $display("Test 2 FAIL: Bit unexpected = %h", wide);
        end

        // Test 3: Zero replication
        test_count++;
        wide = {32{1'b0}};
        if (wide == 32'h00000000) begin
            pass_count++;
            $display("Test 3 PASS: {32{1'b0}} = %h", wide);
        end else begin
            $display("Test 3 FAIL: Zero unexpected = %h", wide);
        end

        // Test 4: Nibble replication
        test_count++;
        begin
            static logic [3:0] nibble = 4'hA;
            wide = {8{nibble}};
            if (wide == 32'hAAAAAAAA) begin
                pass_count++;
                $display("Test 4 PASS: {8{4'hA}} = %h", wide);
            end else begin
                $display("Test 4 FAIL: Nibble unexpected = %h", wide);
            end
        end

        // Test 5: Word replication
        test_count++;
        begin
            static logic [15:0] word = 16'h1234;
            wide = {2{word}};
            if (wide == 32'h12341234) begin
                pass_count++;
                $display("Test 5 PASS: {2{16'h1234}} = %h", wide);
            end else begin
                $display("Test 5 FAIL: Word unexpected = %h", wide);
            end
        end

        // Test 6: Large replication
        test_count++;
        byte_val = 8'hFF;
        bigger = {8{byte_val}};
        if (bigger == 64'hFFFFFFFFFFFFFFFF) begin
            pass_count++;
            $display("Test 6 PASS: {8{8'hFF}} 64-bit = %h", bigger);
        end else begin
            $display("Test 6 FAIL: Large unexpected = %h", bigger);
        end

        // Test 7: Mixed replication and concat
        test_count++;
        begin
            static logic [7:0] a = 8'hAA;
            static logic [7:0] b = 8'hBB;
            wide = {{2{a}}, {2{b}}};
            if (wide == 32'hAAAABBBB) begin
                pass_count++;
                $display("Test 7 PASS: Mixed = %h", wide);
            end else begin
                $display("Test 7 FAIL: Mixed unexpected = %h", wide);
            end
        end

        // Test 8: Nested replication
        test_count++;
        begin
            static logic [1:0] bits = 2'b10;
            static logic [7:0] nested;
            // Assigned here so the result does not depend on the order of static initializers.
            nested = {2{{2{bits}}}};
            if (nested == 8'b10101010) begin
                pass_count++;
                $display("Test 8 PASS: Nested = %b", nested);
            end else begin
                $display("Test 8 FAIL: Nested unexpected = %b", nested);
            end
        end

        // Test 9: Sign extension via replication
        test_count++;
        begin
            static logic [7:0] signed_val = 8'h80;  // -128 in signed
            static logic [15:0] extended;
            // Assigned here so the result does not depend on the order of static initializers.
            extended = {{8{signed_val[7]}}, signed_val};
            if (extended == 16'hFF80) begin
                pass_count++;
                $display("Test 9 PASS: Sign ext = %h", extended);
            end else begin
                $display("Test 9 FAIL: Sign unexpected = %h", extended);
            end
        end

        // Test 10: Alternating pattern
        test_count++;
        begin
            static logic [1:0] alt = 2'b01;
            wide = {16{alt}};
            if (wide == 32'h55555555) begin
                pass_count++;
                $display("Test 10 PASS: Alternating = %h", wide);
            end else begin
                $display("Test 10 FAIL: Alt unexpected = %h", wide);
            end
        end

        // Test 11: Different alternating
        test_count++;
        begin
            static logic [1:0] alt = 2'b10;
            wide = {16{alt}};
            if (wide == 32'hAAAAAAAA) begin
                pass_count++;
                $display("Test 11 PASS: Alt2 = %h", wide);
            end else begin
                $display("Test 11 FAIL: Alt2 unexpected = %h", wide);
            end
        end

        // Test 12: Replication of expression
        test_count++;
        begin
            static logic [3:0] a = 4'h3;
            static logic [3:0] b = 4'h5;
            wide = {8{a ^ b}};  // 3^5 = 6
            if (wide == 32'h66666666) begin
                pass_count++;
                $display("Test 12 PASS: Expr repl = %h", wide);
            end else begin
                $display("Test 12 FAIL: Expr unexpected = %h", wide);
            end
        end

        $display("=== Replication Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
