/*
:name: test_gray_edge_cases
:description: Binary to Gray code and back, and the single-bit change property
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gray_edge_cases.expected
*/
// IEEE 1800-2023: Gray code edge cases
// Tests for Gray code encoding/decoding

module test_gray_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [3:0] binary;
    logic [3:0] gray;
    logic [3:0] decoded;

    // Binary to Gray conversion
    assign gray = binary ^ (binary >> 1);

    // Gray to Binary conversion
    always_comb begin
        decoded[3] = gray[3];
        decoded[2] = decoded[3] ^ gray[2];
        decoded[1] = decoded[2] ^ gray[1];
        decoded[0] = decoded[1] ^ gray[0];
    end

    initial begin
        // Test 1: Binary 0 -> Gray 0
        test_count++;
        binary = 4'b0000;
        #1;
        if (gray == 4'b0000) begin
            pass_count++;
            $display("Test 1 PASS: 0->%b", gray);
        end else begin
            $display("Test 1 FAIL: unexpected gray=%b", gray);
        end

        // Test 2: Binary 1 -> Gray 1
        test_count++;
        binary = 4'b0001;
        #1;
        if (gray == 4'b0001) begin
            pass_count++;
            $display("Test 2 PASS: 1->%b", gray);
        end else begin
            $display("Test 2 FAIL: unexpected gray=%b", gray);
        end

        // Test 3: Binary 2 -> Gray 3
        test_count++;
        binary = 4'b0010;
        #1;
        if (gray == 4'b0011) begin
            pass_count++;
            $display("Test 3 PASS: 2->%b", gray);
        end else begin
            $display("Test 3 FAIL: unexpected gray=%b", gray);
        end

        // Test 4: Binary 3 -> Gray 2
        test_count++;
        binary = 4'b0011;
        #1;
        if (gray == 4'b0010) begin
            pass_count++;
            $display("Test 4 PASS: 3->%b", gray);
        end else begin
            $display("Test 4 FAIL: unexpected gray=%b", gray);
        end

        // Test 5: Decode back to binary
        test_count++;
        binary = 4'b0101;
        #1;
        if (decoded == 4'b0101) begin
            pass_count++;
            $display("Test 5 PASS: Round-trip binary=%b decoded=%b", binary, decoded);
        end else begin
            $display("Test 5 FAIL: unexpected decoded=%b", decoded);
        end

        // Test 6: Single bit change property
        test_count++;
        begin
            static int changes = 0;
            binary = 4'b0000;
            #1;
            for (int i = 1; i < 16; i++) begin
                static logic [3:0] prev_gray;
                // Assigned here so the result does not depend on the order of static initializers.
                prev_gray = gray;
                binary = i[3:0];
                #1;
                // Count bit changes
                changes = 0;
                for (int b = 0; b < 4; b++) begin
                    if (gray[b] != prev_gray[b]) changes++;
                end
                if (changes != 1) break;
            end
            // The loop stops at the first step that changes other than one bit.
            if (changes == 1) begin
                pass_count++;
                $display("Test 6 PASS: Single-bit change property");
            end else begin
                $display("Test 6 FAIL: %0d bits changed", changes);
            end
        end

        // Test 7: Max value
        test_count++;
        binary = 4'b1111;
        #1;
        if (decoded == binary) begin
            pass_count++;
            $display("Test 7 PASS: Max gray=%b decoded=%b", gray, decoded);
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Gray Code Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
