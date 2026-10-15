/*
:name: test_unpacked_2d
:description: 2D unpacked arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_2d.expected
*/
// 2D unpacked arrays
module test_unpacked_2d;
    // Scenario 1: Basic 2D unpacked array
    logic [7:0] arr1 [0:1][0:1];

    // Scenario 2: 2D unpacked array with different bounds
    int arr2 [0:2][0:3];

    // Scenario 3: 2D array initialization
    logic [3:0] arr3 [0:1][0:2];

    // Scenario 4: 2D array element access patterns
    logic [7:0] arr4 [0:2][0:2];

    // Scenario 5: 2D array with loop iteration
    int arr5 [0:1][0:1];
    int sum;

    initial begin
        // Test Scenario 1: Basic 2D unpacked array
        arr1[0][0] = 8'h11;
        arr1[0][1] = 8'h12;
        arr1[1][0] = 8'h21;
        arr1[1][1] = 8'h22;
        if (arr1[0][0] !== 8'h11) begin
            $display("FAIL: Scenario 1 - arr1[0][0] expected 0x11, got 0x%h", arr1[0][0]);
            $finish;
        end
        if (arr1[1][1] !== 8'h22) begin
            $display("FAIL: Scenario 1 - arr1[1][1] expected 0x22, got 0x%h", arr1[1][1]);
            $finish;
        end

        // Test Scenario 2: Different bounds (3x4 array)
        arr2[0][0] = 100;
        arr2[2][3] = 999;
        arr2[1][2] = 500;
        if (arr2[0][0] !== 100) begin
            $display("FAIL: Scenario 2 - arr2[0][0] expected 100, got %0d", arr2[0][0]);
            $finish;
        end
        if (arr2[2][3] !== 999) begin
            $display("FAIL: Scenario 2 - arr2[2][3] expected 999, got %0d", arr2[2][3]);
            $finish;
        end

        // Test Scenario 3: Systematic initialization
        arr3[0][0] = 4'h0;
        arr3[0][1] = 4'h1;
        arr3[0][2] = 4'h2;
        arr3[1][0] = 4'h3;
        arr3[1][1] = 4'h4;
        arr3[1][2] = 4'h5;
        if (arr3[0][2] !== 4'h2) begin
            $display("FAIL: Scenario 3 - arr3[0][2] expected 0x2, got 0x%h", arr3[0][2]);
            $finish;
        end
        if (arr3[1][2] !== 4'h5) begin
            $display("FAIL: Scenario 3 - arr3[1][2] expected 0x5, got 0x%h", arr3[1][2]);
            $finish;
        end

        // Test Scenario 4: Diagonal access
        arr4[0][0] = 8'hAA;
        arr4[1][1] = 8'hBB;
        arr4[2][2] = 8'hCC;
        arr4[0][2] = 8'hDD;
        arr4[2][0] = 8'hEE;
        if (arr4[1][1] !== 8'hBB) begin
            $display("FAIL: Scenario 4 - arr4[1][1] expected 0xBB, got 0x%h", arr4[1][1]);
            $finish;
        end
        if (arr4[0][2] !== 8'hDD) begin
            $display("FAIL: Scenario 4 - arr4[0][2] expected 0xDD, got 0x%h", arr4[0][2]);
            $finish;
        end

        // Test Scenario 5: Loop iteration and sum
        arr5[0][0] = 1;
        arr5[0][1] = 2;
        arr5[1][0] = 3;
        arr5[1][1] = 4;
        sum = 0;
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                sum = sum + arr5[i][j];
            end
        end
        if (sum !== 10) begin
            $display("FAIL: Scenario 5 - Sum expected 10, got %0d", sum);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
