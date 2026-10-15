/*
:name: test_stmt_ext
:description: Test 1: Casex
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.1 12.5.3 12.7.3 12.7.5 12.7.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stmt_ext.expected
*/
// IEEE 1800-2023 §12.5.1, §12.5.3, §12.7.3, §12.7.5 and §12.7.6

module test_stmt_ext;
    int i, result;
    logic flag;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Casex
        test_count++;
        i = 4'b10x0;  // int is 2-state: the x bit becomes 0 (6.11)
        casex (i)
            4'b10?0: result = 1;
            default: result = 0;
        endcase
        if (result == 1) begin
            $display("Test 1: Casex PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%0d", result);
        end

        // Test 2: Casez (first match wins)
        test_count++;
        i = 4'b1010;
        casez (i)
            4'b1?1?: result = 2;
            4'b1?10: result = 3;
            default: result = 0;
        endcase
        if (result == 2) begin
            $display("Test 2: Casez PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%0d", result);
        end

        // Test 3: Do-while
        test_count++;
        i = 0;
        result = 0;
        do begin
            result++;
            i++;
        end while (i < 5);
        if (result == 5) begin
            $display("Test 3: Do-while PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL result=%0d", result);
        end

        // Test 4: Forever with break
        test_count++;
        i = 0;
        forever begin
            i++;
            if (i >= 5) break;
        end
        if (i == 5) begin
            $display("Test 4: Forever PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL i=%0d", i);
        end

        // Test 5: Foreach
        test_count++;
        begin
            static int arr[5] = '{1, 2, 3, 4, 5};
            result = 0;
            foreach (arr[j]) begin
                result += arr[j];
            end
        end
        if (result == 15) begin
            $display("Test 5: Foreach PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL result=%0d", result);
        end

        // Test 6: Nested case
        test_count++;
        i = 2;
        case (i)
            1: case (i) 1: result = 11; default: result = 10; endcase
            2: case (i) 2: result = 22; default: result = 20; endcase
            default: result = 0;
        endcase
        if (result == 22) begin
            $display("Test 6: Nested case PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL result=%0d", result);
        end

        // Test 7: Unique case
        test_count++;
        i = 3;
        unique case (i)
            1: result = 1;
            2: result = 2;
            3: result = 3;
        endcase
        if (result == 3) begin
            $display("Test 7: Unique case PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL result=%0d", result);
        end

        // Test 8: Priority case
        test_count++;
        i = 2;
        priority case (1)
            (i == 1): result = 1;
            (i == 2): result = 2;
            (i == 3): result = 3;
        endcase
        if (result == 2) begin
            $display("Test 8: Priority case PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL result=%0d", result);
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
