/*
:name: test_always_star_for_loop_ieee
:description: Test: For loop variables must NOT be in sensitivity list
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_star_for_loop_ieee.expected
*/
// IEEE 1800-2023 §9.4.2.2 Test: For loop variables must NOT be in sensitivity list
// This test verifies that loop index variables are excluded from the implicit
// sensitivity list in always @(*) blocks.

module test_always_star_for_loop_ieee;
    logic [7:0] data_in [4];
    logic [7:0] data_out [4];
    logic [7:0] inverted [4];

    int pass_count = 0;
    int fail_count = 0;

    // Test 1: For loop in always @(*) - loop index should NOT trigger sensitivity
    always @(*) begin
        for (int i = 0; i < 4; i++) begin
            data_out[i] = data_in[i];
        end
    end

    // Test 2: For loop with inversion - verify processing works
    always @(*) begin
        for (int j = 0; j < 4; j++) begin
            inverted[j] = ~data_in[j];
        end
    end

    // Test 3: Nested for loops - both i and j should be excluded
    logic [7:0] nested_result [2][2];
    logic [7:0] matrix_a [2][2];
    always @(*) begin
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                nested_result[i][j] = matrix_a[i][j] + 1;
            end
        end
    end

    initial begin
        $display("IEEE 1800-2023 §9.4.2.2 Test: For Loop Sensitivity Exclusion");
        $display("");

        // Initialize inputs
        data_in[0] = 8'hAA;
        data_in[1] = 8'hBB;
        data_in[2] = 8'hCC;
        data_in[3] = 8'hDD;

        matrix_a[0][0] = 8'h10;
        matrix_a[0][1] = 8'h20;
        matrix_a[1][0] = 8'h30;
        matrix_a[1][1] = 8'h40;

        #1;

        // Test 1: Verify data_out copies data_in
        $display("Test 1: For loop array copy");
        if (data_out[0] == 8'hAA && data_out[1] == 8'hBB &&
            data_out[2] == 8'hCC && data_out[3] == 8'hDD) begin
            $display("  PASS: data_out = {0x%h, 0x%h, 0x%h, 0x%h}",
                     data_out[0], data_out[1], data_out[2], data_out[3]);
            pass_count++;
        end else begin
            $display("  FAIL: data_out = {0x%h, 0x%h, 0x%h, 0x%h} (expected AA, BB, CC, DD)",
                     data_out[0], data_out[1], data_out[2], data_out[3]);
            fail_count++;
        end

        // Test 2: Verify inversion
        $display("Test 2: For loop inversion");
        if (inverted[0] == 8'h55 && inverted[1] == 8'h44 &&
            inverted[2] == 8'h33 && inverted[3] == 8'h22) begin
            $display("  PASS: inverted = {0x%h, 0x%h, 0x%h, 0x%h}",
                     inverted[0], inverted[1], inverted[2], inverted[3]);
            pass_count++;
        end else begin
            $display("  FAIL: inverted = {0x%h, 0x%h, 0x%h, 0x%h} (expected 55, 44, 33, 22)",
                     inverted[0], inverted[1], inverted[2], inverted[3]);
            fail_count++;
        end

        // Test 3: Verify nested loop
        $display("Test 3: Nested for loops");
        if (nested_result[0][0] == 8'h11 && nested_result[0][1] == 8'h21 &&
            nested_result[1][0] == 8'h31 && nested_result[1][1] == 8'h41) begin
            $display("  PASS: nested_result incremented correctly");
            pass_count++;
        end else begin
            $display("  FAIL: nested_result[0][0]=0x%h, [0][1]=0x%h, [1][0]=0x%h, [1][1]=0x%h",
                     nested_result[0][0], nested_result[0][1],
                     nested_result[1][0], nested_result[1][1]);
            fail_count++;
        end

        // Test 4: Verify sensitivity update
        $display("Test 4: Sensitivity update after data change");
        data_in[0] = 8'hFF;
        #1;
        if (data_out[0] == 8'hFF && inverted[0] == 8'h00) begin
            $display("  PASS: Outputs updated correctly (data_out[0]=0x%h, inverted[0]=0x%h)",
                     data_out[0], inverted[0]);
            pass_count++;
        end else begin
            $display("  FAIL: data_out[0]=0x%h (expected FF), inverted[0]=0x%h (expected 00)",
                     data_out[0], inverted[0]);
            fail_count++;
        end

        // Summary
        $display("");
        $display("========================================");
        $display("TEST RESULTS: %0d/%0d PASSED", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
