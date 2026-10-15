/*
:name: test_loop_nested
:description: Nested Loop Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_nested.expected
*/
// IEEE 1800-2023 Section 12.7 - Nested Loop Tests
module test_loop_nested;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int i, j, count, sum;
        int matrix[2][3];

        $display("=== IEEE 1800-2023 Nested Loop Tests ===");

        $display("Test 1: Double for");
        count = 0;
        for (i = 0; i < 3; i++)
            for (j = 0; j < 4; j++)
                count++;
        if (count == 12) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", count); fail_count++; end

        $display("Test 2: Matrix fill");
        for (i = 0; i < 2; i++)
            for (j = 0; j < 3; j++)
                matrix[i][j] = i * 3 + j;
        if (matrix[0][0] == 0 && matrix[1][2] == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Matrix sum");
        sum = 0;
        for (i = 0; i < 2; i++)
            for (j = 0; j < 3; j++)
                sum = sum + matrix[i][j];
        if (sum == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", sum); fail_count++; end

        $display("Test 4: Inner break");
        count = 0;
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 5; j++) begin
                if (j == 2) break;
                count++;
            end
        end
        if (count == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", count); fail_count++; end

        $display("Test 5: Inner continue");
        count = 0;
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                if (j == 1) continue;
                count++;
            end
        end
        if (count == 6) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", count); fail_count++; end

        $display("Test 6: While in for");
        count = 0;
        for (i = 0; i < 3; i++) begin
            j = 0;
            while (j < 2) begin
                count++;
                j++;
            end
        end
        if (count == 6) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", count); fail_count++; end

        $display("Test 7: Triple nest");
        count = 0;
        for (i = 0; i < 2; i++)
            for (j = 0; j < 2; j++) begin
                int k;
                for (k = 0; k < 2; k++)
                    count++;
            end
        if (count == 8) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", count); fail_count++; end

        $display("Test 8: Index product");
        sum = 0;
        for (i = 1; i <= 3; i++)
            for (j = 1; j <= 3; j++)
                sum = sum + i * j;
        if (sum == 36) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", sum); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
