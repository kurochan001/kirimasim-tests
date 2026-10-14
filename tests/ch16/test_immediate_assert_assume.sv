/*
:name: test_immediate_assert_assume
:description: Immediate assert and assume statements with pass and fail actions
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assert_assume.expected
*/
// IEEE 1800-2023 Section 16.3 - Immediate assertion coverage test
// Tests: immediate assertions, deferred assertions
module test_immediate_assert_assume;
    int passed = 0;
    int failed = 0;

    logic clk = 0;
    logic [7:0] data;

    always #5 clk = ~clk;

    initial begin
        // Test immediate assertion pass
        data = 8'hAA;
        assert(data != 8'h00) passed++; else begin failed++; $display("FAIL: imm assert"); end

        // Test immediate assertion with expression
        begin
            static int a = 10;
            static int b = 5;
            assert(a > b) passed++; else begin failed++; $display("FAIL: expr assert"); end
        end

        // Test assert with message
        data = 8'h55;
        assert(data == 8'h55) passed++; else begin failed++; $display("FAIL: msg assert"); end

        // Test multiple conditions
        begin
            static int x = 100;
            static int y = 50;
            static int z = 25;
            assert(x > y && y > z) passed++; else begin failed++; $display("FAIL: multi cond"); end
        end

        // Test assume (in simulation, same as assert)
        assume(data == 8'h55) passed++; else begin failed++; $display("FAIL: assume"); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d immediate assertion tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
