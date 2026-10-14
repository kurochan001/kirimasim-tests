/*
:name: test_nba_nested_array
:description: Test for NBA with nested array access (IEEE 1800-2023 §10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_nested_array.expected
*/
// Test for NBA with nested array access (IEEE 1800-2023 §10.4.2)
// Verifies non-blocking assignments to multi-dimensional array elements

module test_nba_nested_array;
    // 2D array for basic nested access test
    logic [7:0] arr2d [0:3][0:3];

    // 3D array for deeper nesting test
    logic [7:0] arr3d [0:1][0:1][0:1];

    // Packed dimension with unpacked array
    logic [15:0] packed_arr [0:3];

    int test_count = 0;
    int pass_count = 0;

    task check(string name, logic [31:0] actual, logic [31:0] expected);
        test_count++;
        if (actual === expected) begin
            $display("PASS: %s = %0d (expected %0d)", name, actual, expected);
            pass_count++;
        end else begin
            $display("FAIL: %s = %0d (expected %0d)", name, actual, expected);
        end
    endtask

    initial begin
        // Initialize arrays
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                arr2d[i][j] = 8'h00;
            end
        end

        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                for (int k = 0; k < 2; k++) begin
                    arr3d[i][j][k] = 8'h00;
                end
            end
        end

        for (int i = 0; i < 4; i++) begin
            packed_arr[i] = 16'h0000;
        end

        // Test 1: Simple 2D array NBA
        arr2d[0][0] <= 8'hAA;
        arr2d[1][2] <= 8'hBB;
        arr2d[3][3] <= 8'hCC;
        #1;
        check("arr2d[0][0]", arr2d[0][0], 8'hAA);
        check("arr2d[1][2]", arr2d[1][2], 8'hBB);
        check("arr2d[3][3]", arr2d[3][3], 8'hCC);

        // Test 2: 3D array NBA
        arr3d[0][0][0] <= 8'h11;
        arr3d[0][1][0] <= 8'h22;
        arr3d[1][0][1] <= 8'h33;
        arr3d[1][1][1] <= 8'h44;
        #1;
        check("arr3d[0][0][0]", arr3d[0][0][0], 8'h11);
        check("arr3d[0][1][0]", arr3d[0][1][0], 8'h22);
        check("arr3d[1][0][1]", arr3d[1][0][1], 8'h33);
        check("arr3d[1][1][1]", arr3d[1][1][1], 8'h44);

        // Test 3: Packed array with bit select NBA
        packed_arr[0][7:0] <= 8'hDE;
        packed_arr[1][15:8] <= 8'hAD;
        packed_arr[2][7:0] <= 8'hBE;
        packed_arr[3][15:8] <= 8'hEF;
        #1;
        check("packed_arr[0]", packed_arr[0], 16'h00DE);
        check("packed_arr[1]", packed_arr[1], 16'hAD00);
        check("packed_arr[2]", packed_arr[2], 16'h00BE);
        check("packed_arr[3]", packed_arr[3], 16'hEF00);

        // Test 4: Variable index NBA
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                arr2d[i][j] <= 8'(i * 4 + j);
            end
        end
        #1;
        check("arr2d[0][0] var", arr2d[0][0], 8'd0);
        check("arr2d[1][1] var", arr2d[1][1], 8'd5);
        check("arr2d[2][3] var", arr2d[2][3], 8'd11);
        check("arr2d[3][3] var", arr2d[3][3], 8'd15);

        // Summary
        $display("\n========================================");
        $display("Test Results: %0d/%0d passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
