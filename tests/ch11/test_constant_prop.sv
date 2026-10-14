/*
:name: test_constant_prop
:description: Test for constant propagation
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 6.20.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_prop.expected
*/
// Test for constant propagation
// IEEE 1800-2023 §11

module test_constant_prop;
    localparam A = 10;
    localparam B = 20;
    localparam C = A + B;
    localparam D = C * 2;

    int result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple constant
        test_count++;
        result = A;
        if (result == 10) begin
            $display("Test 1: Simple constant PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Constant addition
        test_count++;
        result = C;
        if (result == 30) begin
            $display("Test 2: Constant addition PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Constant multiplication
        test_count++;
        result = D;
        if (result == 60) begin
            $display("Test 3: Constant multiplication PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Expression with constants
        test_count++;
        result = A + B + 5;
        if (result == 35) begin
            $display("Test 4: Expression with constants PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Constant in conditional
        test_count++;
        result = (A > 5) ? A : B;
        if (result == 10) begin
            $display("Test 5: Constant conditional PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
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
