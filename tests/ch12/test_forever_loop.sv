/*
:name: test_forever_loop
:description: Test: forever loop with break
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.6 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forever_loop.expected
*/
// Test: forever loop with break

module test_forever_loop;
    int pass_count = 0;
    int total_tests = 6;

    // Test variables
    int count;
    int sum;
    logic [7:0] data;
    logic clk;

    initial begin
        clk = 0;

        // Test 1: Forever loop with break
        count = 0;
        forever begin
            count++;
            if (count >= 5) break;
        end
        if (count == 5) pass_count++;

        // Test 2: Forever loop with sum accumulation
        sum = 0;
        count = 0;
        forever begin
            sum += count;
            count++;
            if (count >= 10) break;
        end
        if (sum == 45) pass_count++;  // 0+1+2+...+9 = 45

        // Test 3: Forever loop with bit manipulation
        data = 8'hFF;
        count = 0;
        forever begin
            data = data >> 1;
            count++;
            if (data == 0) break;
        end
        if (count == 8) pass_count++;

        // Test 4: Forever loop with conditional break
        count = 0;
        sum = 0;
        forever begin
            count++;
            if (count % 2 == 0) begin
                sum += count;
            end
            if (sum >= 20) break;
        end
        if (sum >= 20) pass_count++;

        // Test 5: Forever loop with complex condition
        count = 0;
        sum = 1;
        forever begin
            sum = sum * 2;
            count++;
            if (sum >= 64 || count >= 10) break;
        end
        if (sum == 64 && count == 6) pass_count++;

        // Test 6: Nested forever with inner break
        count = 0;
        sum = 0;
        forever begin
            count++;
            forever begin
                sum++;
                if (sum >= 3 * count) break;
            end
            if (count >= 4) break;
        end
        // count=1: sum+=3, count=2: sum+=3, count=3: sum+=3, count=4: sum+=3
        if (count == 4 && sum == 12) pass_count++;

        $display("PASS: forever_loop (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
