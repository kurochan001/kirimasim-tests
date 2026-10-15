/*
:name: test_array_assign
:description: Assigning unpacked array elements, including 2-D, 3-D and packed element types
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_assign.expected
*/
// Assigning unpacked array elements, including 2-D, 3-D and packed element types

module test_array_assign;
    int pass_count = 0;
    int total_tests = 15;

    logic [7:0] arr1 [0:3];
    logic [7:0] arr2 [0:3];
    int int_arr [0:7];
    logic [15:0] word_arr [0:3];

    // Multi-dimensional arrays
    logic [7:0] matrix [0:2][0:2];
    int cube [0:1][0:1][0:1];

    // Array of packed types
    logic [3:0][7:0] packed_arr [0:1];

    int idx;
    logic [7:0] temp;

    initial begin
        // Test 1: Simple array element assignment
        arr1[0] = 8'hAA;
        arr1[1] = 8'hBB;
        arr1[2] = 8'hCC;
        arr1[3] = 8'hDD;
        if (arr1[0] == 8'hAA && arr1[3] == 8'hDD) begin
            pass_count++;
            $display("PASS: Simple array element assign");
        end else $display("FAIL: Simple array element assign");

        // Test 2: Array element read and assign
        arr2[0] = arr1[2];
        if (arr2[0] == 8'hCC) begin
            pass_count++;
            $display("PASS: Array read and assign");
        end else $display("FAIL: Array read and assign");

        // Test 3: Variable index assignment
        idx = 2;
        arr1[idx] = 8'hEE;
        if (arr1[2] == 8'hEE) begin
            pass_count++;
            $display("PASS: Variable index assignment");
        end else $display("FAIL: Variable index assignment");

        // Test 4: Expression index assignment
        arr1[idx + 1] = 8'hFF;
        if (arr1[3] == 8'hFF) begin
            pass_count++;
            $display("PASS: Expression index assignment");
        end else $display("FAIL: Expression index assignment");

        // Test 5: Array element swap
        arr1[0] = 8'h11;
        arr1[1] = 8'h22;
        temp = arr1[0];
        arr1[0] = arr1[1];
        arr1[1] = temp;
        if (arr1[0] == 8'h22 && arr1[1] == 8'h11) begin
            pass_count++;
            $display("PASS: Array element swap");
        end else $display("FAIL: Array element swap");

        // Test 6: Loop assignment to array
        for (int i = 0; i < 8; i++) begin
            int_arr[i] = i * 10;
        end
        if (int_arr[0] == 0 && int_arr[5] == 50 && int_arr[7] == 70) begin
            pass_count++;
            $display("PASS: Loop assignment to array");
        end else $display("FAIL: Loop assignment to array");

        // Test 7: 2D matrix assignment
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                matrix[i][j] = i * 3 + j;
            end
        end
        if (matrix[0][0] == 0 && matrix[1][1] == 4 && matrix[2][2] == 8) begin
            pass_count++;
            $display("PASS: 2D matrix assignment");
        end else $display("FAIL: 2D matrix assignment");

        // Test 8: 2D element access
        matrix[1][2] = 8'hAB;
        if (matrix[1][2] == 8'hAB) begin
            pass_count++;
            $display("PASS: 2D element access");
        end else $display("FAIL: 2D element access");

        // Test 9: 3D cube assignment
        cube[0][0][0] = 1;
        cube[0][0][1] = 2;
        cube[0][1][0] = 3;
        cube[1][1][1] = 8;
        if (cube[0][0][0] == 1 && cube[1][1][1] == 8) begin
            pass_count++;
            $display("PASS: 3D cube assignment");
        end else $display("FAIL: 3D cube assignment");

        // Test 10: Array of packed assignment
        packed_arr[0] = 32'hDEADBEEF;
        packed_arr[1] = 32'hCAFEBABE;
        if (packed_arr[0] == 32'hDEADBEEF && packed_arr[1] == 32'hCAFEBABE) begin
            pass_count++;
            $display("PASS: Array of packed assignment");
        end else $display("FAIL: Array of packed assignment");

        // Test 11: Array element with compound operation
        int_arr[3] = 100;
        int_arr[3] += 50;
        if (int_arr[3] == 150) begin
            pass_count++;
            $display("PASS: Array compound assignment");
        end else $display("FAIL: Array compound assignment");

        // Test 12: Array copy element by element
        for (int i = 0; i < 4; i++) begin
            arr2[i] = arr1[i];
        end
        if (arr2[0] == arr1[0] && arr2[3] == arr1[3]) begin
            pass_count++;
            $display("PASS: Array copy element by element");
        end else $display("FAIL: Array copy element by element");

        // Test 13: Boundary index assignment
        arr1[0] = 8'h00;  // First element
        arr1[3] = 8'hFF;  // Last element
        if (arr1[0] == 8'h00 && arr1[3] == 8'hFF) begin
            pass_count++;
            $display("PASS: Boundary index assignment");
        end else $display("FAIL: Boundary index assignment");

        // Test 14: Word array assignment
        word_arr[0] = 16'h1234;
        word_arr[1] = 16'h5678;
        if (word_arr[0] == 16'h1234 && word_arr[1] == 16'h5678) begin
            pass_count++;
            $display("PASS: Word array assignment");
        end else $display("FAIL: Word array assignment");

        // Test 15: Assign with arithmetic expression
        int_arr[0] = 100;
        int_arr[1] = int_arr[0] / 2 + 25;  // 50 + 25 = 75
        if (int_arr[1] == 75) begin
            pass_count++;
            $display("PASS: Array assign with arithmetic");
        end else $display("FAIL: Array assign with arithmetic");

        $display("PASS: array_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
