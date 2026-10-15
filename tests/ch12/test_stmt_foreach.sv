/*
:name: test_stmt_foreach
:description: Foreach loops test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_foreach.expected
*/
// Foreach loops test
module test_foreach;
    int arr[5];
    int arr2d[3][4];
    int sum, result;
    int pass_count = 0;

    initial begin
        // Scenario 1: Simple foreach loop
        arr = '{10, 20, 30, 40, 50};
        sum = 0;
        foreach (arr[i]) begin
            sum = sum + arr[i];
        end
        if (sum == 150) pass_count++;
        else $display("FAIL: Simple foreach loop sum=%0d", sum);

        // Scenario 2: Foreach with modification
        foreach (arr[i]) begin
            arr[i] = i * 2;
        end
        if (arr[0] == 0 && arr[2] == 4 && arr[4] == 8) pass_count++;
        else $display("FAIL: Foreach with modification");

        // Scenario 3: Foreach on 2D array
        sum = 0;
        foreach (arr2d[i, j]) begin
            arr2d[i][j] = i + j;
            sum = sum + 1;
        end
        if (sum == 12) pass_count++;  // 3*4=12 iterations
        else $display("FAIL: Foreach on 2D array sum=%0d", sum);

        // Scenario 4: Foreach with index usage
        result = 0;
        foreach (arr[i]) begin
            result = result + i;
        end
        if (result == 10) pass_count++;  // 0+1+2+3+4=10
        else $display("FAIL: Foreach with index usage result=%0d", result);

        // Scenario 5: Foreach with conditional
        arr = '{1, 2, 3, 4, 5};
        sum = 0;
        foreach (arr[i]) begin
            if (arr[i] % 2 == 0) sum = sum + arr[i];
        end
        if (sum == 6) pass_count++;  // 2+4=6
        else $display("FAIL: Foreach with conditional sum=%0d", sum);

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
