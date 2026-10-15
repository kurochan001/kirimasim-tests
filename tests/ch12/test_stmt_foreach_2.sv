/*
:name: test_stmt_foreach_2
:description: Test for foreach loop
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_foreach_2.expected
*/
// Test for foreach loop
// IEEE 1800-2023 §12.7.3: Foreach loop
module test_stmt_foreach;
    int fails = 0;

    initial begin
        static int arr[5] = '{1, 2, 3, 4, 5};
        int sum;
        int dyn[];
        int assoc[string];

        // Simple foreach
        sum = 0;
        foreach (arr[i]) begin
            sum += arr[i];
        end
        if (sum != 15) begin fails++; $display("FAIL: Simple foreach %0d", sum); end

        // Foreach with index
        sum = 0;
        foreach (arr[i]) begin
            sum += i;
        end
        if (sum != 10) begin fails++; $display("FAIL: Foreach index %0d", sum); end

        // Dynamic array foreach
        dyn = new[3];
        dyn[0] = 10;
        dyn[1] = 20;
        dyn[2] = 30;
        sum = 0;
        foreach (dyn[i]) begin
            sum += dyn[i];
        end
        if (sum != 60) begin fails++; $display("FAIL: Dynamic foreach %0d", sum); end

        // Associative array foreach
        assoc["a"] = 1;
        assoc["b"] = 2;
        assoc["c"] = 3;
        sum = 0;
        foreach (assoc[key]) begin
            sum += assoc[key];
        end
        if (sum != 6) begin fails++; $display("FAIL: Assoc foreach %0d", sum); end

        if (fails == 0) $display("PASS: Foreach loop");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
