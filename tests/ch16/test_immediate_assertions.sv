/*
:name: test_immediate_assertions
:description: Chapter 16: Assertions
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertions.expected
*/
// IEEE 1800-2023 Chapter 16: Assertions
// §16.3 Immediate assertions

module test_immediate_assertions;
    int test_count;
    int pass_count;

    int value;
    logic [7:0] data;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Simple assert pass
        value = 10;
        test_count++;
        begin
            assert (value > 5);
            pass_count++;
        end

        // Test 2: Assert with else (pass case)
        value = 20;
        test_count++;
        assert (value >= 10) else begin
            $display("FAIL: assert with else");
        end
        pass_count++;

        // Test 3: Assert expression
        data = 8'hAB;
        test_count++;
        assert (data != 8'h00) else begin
            $display("FAIL: data assertion");
        end
        pass_count++;

        // Test 4: assume directive (compile-time only)
        value = 100;
        test_count++;
        assume (value > 0);  // For formal verification
        pass_count++;

        // Test 5: cover directive
        test_count++;
        cover (value == 100);  // Coverage point
        pass_count++;

        // Test 6: Multiple conditions
        value = 50;
        data = 8'hFF;
        test_count++;
        assert (value > 0 && data != 8'h00) else begin
            $display("FAIL: multiple conditions");
        end
        pass_count++;

        $display("Chapter 16.3 Immediate Assertions: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
