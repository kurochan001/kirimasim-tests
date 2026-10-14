/*
:name: test_assign_nba
:description: Non-blocking assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_nba.expected
*/
// IEEE 1800-2023 §10.4.2: Non-blocking assignments
module test_assign_nba;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] a, b;
    logic clk = 0;

    always #5 clk = ~clk;

    initial begin
        // Test 1: NBA deferred
        a = 8'h00;
        a <= 8'hAA;
        if (a == 8'h00) begin
            $display("Test 1 PASS: NBA deferred, still %02h", a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", a);
            fail_count++;
        end

        #1;
        // Test 2: NBA applied
        if (a == 8'hAA) begin
            $display("Test 2 PASS: NBA applied = %02h", a);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", a);
            fail_count++;
        end

        // Test 3: Multiple NBAs to same var
        a <= 8'h11;
        a <= 8'h22;
        a <= 8'h33;
        #1;
        if (a == 8'h33) begin
            $display("Test 3 PASS: last NBA wins = %02h", a);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", a);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
