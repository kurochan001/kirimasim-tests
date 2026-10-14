/*
:name: test_isunknown_2
:description: Test for $isunknown function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_isunknown_2.expected
*/
// Test for $isunknown function
// IEEE 1800-2023 Section 20.9

module test_isunknown;
    logic [7:0] test_vec;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: No unknown bits
        test_count++;
        test_vec = 8'b0000_0000;
        if (!$isunknown(test_vec)) begin
            $display("Test 1: $isunknown(8'b00000000) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: All ones, no unknown
        test_count++;
        test_vec = 8'b1111_1111;
        if (!$isunknown(test_vec)) begin
            $display("Test 2: $isunknown(8'b11111111) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: With X value
        test_count++;
        test_vec = 8'b0000_000x;
        if ($isunknown(test_vec)) begin
            $display("Test 3: $isunknown(8'b0000000x) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: With Z value
        test_count++;
        test_vec = 8'b0000_000z;
        if ($isunknown(test_vec)) begin
            $display("Test 4: $isunknown(8'b0000000z) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Mixed X and Z
        test_count++;
        test_vec = 8'bxxxx_zzzz;
        if ($isunknown(test_vec)) begin
            $display("Test 5: $isunknown(8'bxxxxzzzz) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: X in middle
        test_count++;
        test_vec = 8'b1111_x111;
        if ($isunknown(test_vec)) begin
            $display("Test 6: $isunknown(8'b1111x111) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
        end

        // Test 7: Integer (no unknown)
        test_count++;
        if (!$isunknown(100)) begin
            $display("Test 7: $isunknown(100) = 0 PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL");
        end

        // Test 8: All X
        test_count++;
        test_vec = 8'bxxxx_xxxx;
        if ($isunknown(test_vec)) begin
            $display("Test 8: $isunknown(8'bxxxxxxxx) = 1 PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL");
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
