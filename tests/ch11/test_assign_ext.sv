/*
:name: test_assign_ext
:description: Test 1: Multiple part select
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1 11.5.1 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_ext.expected
*/
// IEEE 1800-2023 §10

module test_assign_ext;
    logic [31:0] a, b;
    logic [7:0] arr[4];
    int q[$];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Multiple part select
        test_count++;
        a = 32'h00000000;
        a[7:0] = 8'hAA;
        a[15:8] = 8'hBB;
        a[23:16] = 8'hCC;
        a[31:24] = 8'hDD;
        if (a == 32'hDDCCBBAA) begin
            $display("Test 1: Multi part select PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL a=%h", a);
        end

        // Test 2: Array slice
        test_count++;
        arr[0] = 8'h10;
        arr[1] = 8'h20;
        arr[2] = 8'h30;
        arr[3] = 8'h40;
        if (arr[0] == 8'h10 && arr[3] == 8'h40) begin
            $display("Test 2: Array slice PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Compound multiply
        test_count++;
        a = 10;
        a *= 5;
        if (a == 50) begin
            $display("Test 3: Compound *= PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL a=%0d", a);
        end

        // Test 4: Compound divide
        test_count++;
        a = 100;
        a /= 4;
        if (a == 25) begin
            $display("Test 4: Compound /= PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL a=%0d", a);
        end

        // Test 5: Compound modulo
        test_count++;
        a = 17;
        a %= 5;
        if (a == 2) begin
            $display("Test 5: Compound %%= PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL a=%0d", a);
        end

        // Test 6: Compound AND
        test_count++;
        a = 32'hFF00FF00;
        a &= 32'h0F0F0F0F;
        if (a == 32'h0F000F00) begin
            $display("Test 6: Compound &= PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL a=%h", a);
        end

        // Test 7: Compound OR
        test_count++;
        a = 32'h00FF00FF;
        a |= 32'hF0F0F0F0;
        if (a == 32'hF0FFF0FF) begin
            $display("Test 7: Compound |= PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL a=%h", a);
        end

        // Test 8: Queue push
        test_count++;
        q.push_back(1);
        q.push_back(2);
        q.push_back(3);
        if (q.size() == 3) begin
            $display("Test 8: Queue push PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL size=%0d", q.size());
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
