/*
:name: test_array_element_assign
:description: Test for array element assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_element_assign.expected
*/
// Test for array element assignment
// IEEE 1800-2023 Section 7.4

module test_array_element_assign;
    int pass_count = 0;
    int test_count = 0;
    
    int arr_1d[10];
    int arr_2d[4][4];
    logic [31:0] packed_arr;
    logic [7:0] byte_arr[4];

    initial begin
        // Test 1: 1D array element assignment
        test_count++;
        for (int i = 0; i < 10; i++) begin
            arr_1d[i] = i * 10;
        end
        if (arr_1d[5] == 50) begin
            $display("Test 1: 1D array element PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL arr_1d[5]=%0d", arr_1d[5]);
        end

        // Test 2: 2D array element assignment
        test_count++;
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                arr_2d[i][j] = i * 4 + j;
            end
        end
        if (arr_2d[2][3] == 11) begin
            $display("Test 2: 2D array element PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL arr_2d[2][3]=%0d", arr_2d[2][3]);
        end

        // Test 3: Packed array bit select
        test_count++;
        packed_arr = 32'h0;
        packed_arr[15:8] = 8'hAB;
        if (packed_arr[15:8] == 8'hAB) begin
            $display("Test 3: Packed range select PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Array of bytes
        test_count++;
        for (int i = 0; i < 4; i++) begin
            byte_arr[i] = i + 8'h10;
        end
        if (byte_arr[2] == 8'h12) begin
            $display("Test 4: Byte array PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Variable index assignment
        test_count++;
        begin
            int idx;
            idx = 3;
            arr_1d[idx] = 999;
            if (arr_1d[3] == 999) begin
                $display("Test 5: Variable index PASS");
                pass_count++;
            end else begin
                $display("Test 5: FAIL");
            end
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
