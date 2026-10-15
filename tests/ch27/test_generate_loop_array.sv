/*
:name: test_generate_loop_array
:description: Loop and if generate constructs driving an array, checked in a loop
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_loop_array.expected
*/
// Test: Loop, if and nested generate constructs driving an array
module test_generate_loop_array;
    int pass_count = 0;
    int test_count = 0;

    // Generate loop with array
    logic [7:0] data[8];

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : gen_init
            assign data[i] = i * 2;
        end
    endgenerate

    // Generate conditional
    parameter USE_FEATURE = 1;

    generate
        if (USE_FEATURE) begin : gen_feature
            logic [7:0] feature_data;
            assign feature_data = 8'hAA;
        end
    endgenerate

    // Nested generate
    generate
        for (i = 0; i < 4; i++) begin : gen_outer
            for (genvar j = 0; j < 2; j++) begin : gen_inner
                // Nested generate block
            end
        end
    endgenerate

    initial begin
        #1;

        // Test 1: Generated array element 0
        test_count++;
        if (data[0] == 0) pass_count++;

        // Test 2: Generated array element 1
        test_count++;
        if (data[1] == 2) pass_count++;

        // Test 3: Generated array element 7
        test_count++;
        if (data[7] == 14) pass_count++;

        // Test 4: Conditional generate
        test_count++;
        if (gen_feature.feature_data == 8'hAA) pass_count++;

        // Test 5: All array elements correct
        test_count++;
        begin
            static int ok = 1;
            for (int k = 0; k < 8; k++) begin
                if (data[k] != k * 2) ok = 0;
            end
            if (ok) pass_count++;
        end

        // Test 6: Sum of generated values
        test_count++;
        begin
            static int sum = 0;
            for (int k = 0; k < 8; k++) begin
                sum += data[k];
            end
            if (sum == 56) pass_count++;  // 0+2+4+6+8+10+12+14 = 56
        end

        // Test 7: Max value
        test_count++;
        begin
            static int max_val = 0;
            for (int k = 0; k < 8; k++) begin
                if (data[k] > max_val) max_val = data[k];
            end
            if (max_val == 14) pass_count++;
        end

        // Test 8: Min value
        test_count++;
        if (data[0] == 0) pass_count++;

        // Test 9: Middle value
        test_count++;
        if (data[4] == 8) pass_count++;

        // Test 10: Pattern check
        test_count++;
        if (data[3] - data[2] == 2) pass_count++;

        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
