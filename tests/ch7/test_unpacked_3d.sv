/*
:name: test_unpacked_3d
:description: 3D unpacked arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_3d.expected
*/
// 3D unpacked arrays
module test_unpacked_3d;
    // Scenario 1: Basic 3D unpacked array
    logic [7:0] arr1 [0:1][0:1][0:1];

    // Scenario 2: 3D array with different sizes
    int arr2 [0:1][0:2][0:3];

    // Scenario 3: 3D array element access
    logic [3:0] arr3 [0:1][0:1][0:2];

    // Scenario 4: 3D array with computed indices
    logic [7:0] arr4 [0:2][0:2][0:2];
    int idx;

    // Scenario 5: 3D array sum with loops
    int arr5 [0:1][0:1][0:1];
    int sum;

    initial begin
        // Test Scenario 1: Basic 3D (2x2x2 = 8 elements)
        arr1[0][0][0] = 8'h00;
        arr1[0][0][1] = 8'h01;
        arr1[0][1][0] = 8'h10;
        arr1[0][1][1] = 8'h11;
        arr1[1][0][0] = 8'h20;
        arr1[1][0][1] = 8'h21;
        arr1[1][1][0] = 8'h30;
        arr1[1][1][1] = 8'h31;

        if (arr1[0][0][0] !== 8'h00) begin
            $display("FAIL: Scenario 1 - arr1[0][0][0] expected 0x00, got 0x%h", arr1[0][0][0]);
            $finish;
        end
        if (arr1[1][1][1] !== 8'h31) begin
            $display("FAIL: Scenario 1 - arr1[1][1][1] expected 0x31, got 0x%h", arr1[1][1][1]);
            $finish;
        end

        // Test Scenario 2: Different sizes (2x3x4 = 24 elements)
        arr2[0][0][0] = 100;
        arr2[1][2][3] = 999;
        arr2[0][1][2] = 500;
        if (arr2[0][0][0] !== 100) begin
            $display("FAIL: Scenario 2 - arr2[0][0][0] expected 100, got %0d", arr2[0][0][0]);
            $finish;
        end
        if (arr2[1][2][3] !== 999) begin
            $display("FAIL: Scenario 2 - arr2[1][2][3] expected 999, got %0d", arr2[1][2][3]);
            $finish;
        end

        // Test Scenario 3: Sequential initialization
        arr3[0][0][0] = 4'h0;
        arr3[0][0][1] = 4'h1;
        arr3[0][0][2] = 4'h2;
        arr3[0][1][0] = 4'h3;
        arr3[0][1][1] = 4'h4;
        arr3[0][1][2] = 4'h5;
        arr3[1][0][0] = 4'h6;
        arr3[1][0][1] = 4'h7;
        arr3[1][0][2] = 4'h8;
        arr3[1][1][0] = 4'h9;
        arr3[1][1][1] = 4'hA;
        arr3[1][1][2] = 4'hB;

        if (arr3[1][0][2] !== 4'h8) begin
            $display("FAIL: Scenario 3 - arr3[1][0][2] expected 0x8, got 0x%h", arr3[1][0][2]);
            $finish;
        end
        if (arr3[1][1][2] !== 4'hB) begin
            $display("FAIL: Scenario 3 - arr3[1][1][2] expected 0xB, got 0x%h", arr3[1][1][2]);
            $finish;
        end

        // Test Scenario 4: Computed indices
        idx = 1;
        arr4[idx][idx][idx] = 8'hFF;
        arr4[idx+1][idx][idx-1] = 8'hAA;
        if (arr4[1][1][1] !== 8'hFF) begin
            $display("FAIL: Scenario 4 - arr4[1][1][1] expected 0xFF, got 0x%h", arr4[1][1][1]);
            $finish;
        end
        if (arr4[2][1][0] !== 8'hAA) begin
            $display("FAIL: Scenario 4 - arr4[2][1][0] expected 0xAA, got 0x%h", arr4[2][1][0]);
            $finish;
        end

        // Test Scenario 5: Sum with nested loops
        arr5[0][0][0] = 1;
        arr5[0][0][1] = 2;
        arr5[0][1][0] = 3;
        arr5[0][1][1] = 4;
        arr5[1][0][0] = 5;
        arr5[1][0][1] = 6;
        arr5[1][1][0] = 7;
        arr5[1][1][1] = 8;
        sum = 0;
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                for (int k = 0; k < 2; k++) begin
                    sum = sum + arr5[i][j][k];
                end
            end
        end
        if (sum !== 36) begin
            $display("FAIL: Scenario 5 - Sum expected 36, got %0d", sum);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
