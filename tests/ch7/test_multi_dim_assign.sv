/*
:name: test_multi_dim_assign
:description: Test: Multi-dimensional array assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 7.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multi_dim_assign.expected
*/
// Test: Multi-dimensional array assignment

module test_multi_dim_assign;
    int pass_count = 0;
    int total_tests = 15;

    logic [7:0] matrix [0:2][0:2];
    int grid [0:3][0:3];

    logic [3:0] cube [0:1][0:1][0:1];

    // Mixed dimension types
    logic [7:0] mixed_2d [0:1][0:3];
    int mixed_3d [0:1][0:2][0:1];

    // Packed multi-dimensional
    logic [1:0][3:0][7:0] packed_3d;

    int dyn_of_fixed [][0:3];

    int i, j, k;
    int temp;

    initial begin
        // Test 1: 2D matrix element assignment
        matrix[0][0] = 8'h11;
        matrix[0][1] = 8'h12;
        matrix[1][0] = 8'h21;
        matrix[2][2] = 8'h33;
        if (matrix[0][0] == 8'h11 && matrix[2][2] == 8'h33) begin
            pass_count++;
            $display("PASS: 2D matrix element");
        end else $display("FAIL: 2D matrix element");

        // Test 2: 2D loop initialization
        for (i = 0; i < 4; i++) begin
            for (j = 0; j < 4; j++) begin
                grid[i][j] = i * 10 + j;
            end
        end
        if (grid[0][0] == 0 && grid[1][2] == 12 && grid[3][3] == 33) begin
            pass_count++;
            $display("PASS: 2D loop initialization");
        end else $display("FAIL: 2D loop initialization");

        // Test 3: 2D row access pattern
        for (j = 0; j < 4; j++) begin
            grid[0][j] = 100 + j;
        end
        if (grid[0][0] == 100 && grid[0][3] == 103) begin
            pass_count++;
            $display("PASS: 2D row access");
        end else $display("FAIL: 2D row access");

        // Test 4: 2D column access pattern
        for (i = 0; i < 4; i++) begin
            grid[i][0] = 200 + i;
        end
        if (grid[0][0] == 200 && grid[3][0] == 203) begin
            pass_count++;
            $display("PASS: 2D column access");
        end else $display("FAIL: 2D column access");

        // Test 5: 3D cube element assignment
        cube[0][0][0] = 4'h1;
        cube[0][0][1] = 4'h2;
        cube[0][1][0] = 4'h3;
        cube[1][1][1] = 4'h8;
        if (cube[0][0][0] == 4'h1 && cube[1][1][1] == 4'h8) begin
            pass_count++;
            $display("PASS: 3D cube element");
        end else $display("FAIL: 3D cube element");

        // Test 6: 3D loop initialization
        for (i = 0; i < 2; i++) begin
            for (j = 0; j < 2; j++) begin
                for (k = 0; k < 2; k++) begin
                    cube[i][j][k] = i * 4 + j * 2 + k;
                end
            end
        end
        if (cube[0][0][0] == 0 && cube[1][1][1] == 7) begin
            pass_count++;
            $display("PASS: 3D loop initialization");
        end else $display("FAIL: 3D loop initialization");

        // Test 7: Variable indices in 2D
        i = 1; j = 2;
        matrix[i][j] = 8'hAB;
        if (matrix[1][2] == 8'hAB) begin
            pass_count++;
            $display("PASS: Variable indices 2D");
        end else $display("FAIL: Variable indices 2D");

        // Test 8: Expression indices
        matrix[i+1][j-1] = 8'hCD;  // matrix[2][1]
        if (matrix[2][1] == 8'hCD) begin
            pass_count++;
            $display("PASS: Expression indices");
        end else $display("FAIL: Expression indices");

        // Test 9: Mixed dimension array
        for (i = 0; i < 2; i++) begin
            for (j = 0; j < 4; j++) begin
                mixed_2d[i][j] = (i << 4) | j;
            end
        end
        if (mixed_2d[0][0] == 8'h00 && mixed_2d[1][3] == 8'h13) begin
            pass_count++;
            $display("PASS: Mixed dimension 2D");
        end else $display("FAIL: Mixed dimension 2D");

        // Test 10: Packed 3D assignment (whole)
        packed_3d = 64'hDEADBEEFCAFEBABE;
        if (packed_3d == 64'hDEADBEEFCAFEBABE) begin
            pass_count++;
            $display("PASS: Packed 3D whole");
        end else $display("FAIL: Packed 3D whole");

        // Test 11: Packed 3D element access
        packed_3d[0][0] = 8'hFF;
        packed_3d[1][3] = 8'h00;
        if (packed_3d[0][0] == 8'hFF) begin
            pass_count++;
            $display("PASS: Packed 3D element");
        end else $display("FAIL: Packed 3D element");

        // Test 12: 2D swap elements
        grid[0][0] = 111;
        grid[1][1] = 222;
        temp = grid[0][0];
        grid[0][0] = grid[1][1];
        grid[1][1] = temp;
        if (grid[0][0] == 222 && grid[1][1] == 111) begin
            pass_count++;
            $display("PASS: 2D swap elements");
        end else $display("FAIL: 2D swap elements");

        // Test 13: 2D compound assignment
        grid[2][2] = 100;
        grid[2][2] += 50;
        if (grid[2][2] == 150) begin
            pass_count++;
            $display("PASS: 2D compound assignment");
        end else $display("FAIL: 2D compound assignment");

        // Test 14: 2D from expression
        grid[0][1] = 10;
        grid[1][0] = 20;
        grid[1][1] = grid[0][1] + grid[1][0];
        if (grid[1][1] == 30) begin
            pass_count++;
            $display("PASS: 2D from expression");
        end else $display("FAIL: 2D from expression");

        // Test 15: Boundary elements
        mixed_3d[0][0][0] = 1;
        mixed_3d[1][2][1] = 999;
        if (mixed_3d[0][0][0] == 1 && mixed_3d[1][2][1] == 999) begin
            pass_count++;
            $display("PASS: Boundary elements");
        end else $display("FAIL: Boundary elements");

        if (pass_count == total_tests) $display("PASS: multi_dim_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: multi_dim_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
