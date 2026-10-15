/*
:name: test_randsequence
:description: randsequence test
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17 18.17.1 18.17.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence.expected
*/
// IEEE 1800-2023 Section 18.17: randsequence test
// Tests basic randsequence functionality

module test_randsequence;
    int production_count;
    int result;

    initial begin
        production_count = 0;
        result = 0;

        // Test 1: Simple production sequence
        $display("Test 1: Simple production sequence");
        randsequence(main)
            main : first second third;
            first : { production_count++; $display("  first production"); };
            second : { production_count++; $display("  second production"); };
            third : { production_count++; $display("  third production"); };
        endsequence

        if (production_count == 3) begin
            $display("PASS: Simple sequence executed 3 productions");
            result++;
        end else begin
            $display("FAIL: Expected 3 productions, got %0d", production_count);
        end

        // Test 2: Weighted random selection
        $display("\nTest 2: Weighted random selection");
        production_count = 0;
        repeat (10) begin
            randsequence(weighted_main)
                weighted_main : opt_a := 1 | opt_b := 1;
                opt_a : { production_count++; };
                opt_b : { production_count++; };
            endsequence
        end

        if (production_count == 10) begin
            $display("PASS: Weighted selection executed 10 times");
            result++;
        end else begin
            $display("FAIL: Expected 10 executions, got %0d", production_count);
        end

        // Test 3: Code block in production
        $display("\nTest 3: Code block in production");
        production_count = 0;
        randsequence(code_main)
            code_main : code_prod;
            code_prod : {
                production_count = 100;
                $display("  Code block executed");
            };
        endsequence

        if (production_count == 100) begin
            $display("PASS: Code block executed correctly");
            result++;
        end else begin
            $display("FAIL: Code block not executed correctly, got %0d", production_count);
        end

        // Summary
        $display("\n=== Test Summary ===");
        if (result == 3) begin
            $display("All tests PASSED (%0d/3)", result);
        end else begin
            $display("Some tests FAILED (%0d/3 passed)", result);
        end

        $finish;
    end
endmodule
