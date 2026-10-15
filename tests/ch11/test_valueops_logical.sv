/*
:name: test_valueops_logical
:description: Logical AND, OR and NOT on int values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_logical.expected
*/
// IEEE 1800-2023 §11.4: Logical operations
module test_valueops_logical;
    int pass_count = 0;
    int fail_count = 0;
    logic a, b, c;
    int x, y;

    initial begin
        // Test 1: Logical AND
        x = 5;
        y = 10;
        if (x && y) begin
            $display("Test 1 PASS: logical AND");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Logical OR
        x = 0;
        y = 5;
        if (x || y) begin
            $display("Test 2 PASS: logical OR");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Logical NOT
        x = 0;
        if (!x) begin
            $display("Test 3 PASS: logical NOT");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
