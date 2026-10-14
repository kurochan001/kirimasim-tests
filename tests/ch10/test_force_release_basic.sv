/*
:name: test_force_release_basic
:description: force and release procedural statements
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_release_basic.expected
*/
// IEEE 1800-2023 §10.6.2: force and release procedural statements
module test_force_release_basic;
    logic [7:0] sig;
    logic clk = 0;
    int pass_count = 0;
    int fail_count = 0;

    always #5 clk = ~clk;

    initial begin
        // Test 1: Basic force
        sig = 8'h00;
        #1;
        force sig = 8'hAB;
        #1;
        if (sig == 8'hAB) begin
            $display("Test 1 PASS: force applied, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: expected AB, got %02h", sig);
            fail_count++;
        end

        // Test 2: Force with different value
        release sig;
        force sig = 8'hCD;
        #1;
        if (sig == 8'hCD) begin
            $display("Test 2 PASS: force changed, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: expected CD, got %02h", sig);
            fail_count++;
        end

        // Test 3: Release
        release sig;
        sig = 8'hEF;
        #1;
        if (sig == 8'hEF) begin
            $display("Test 3 PASS: release allows assignment, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: release failed, got %02h", sig);
            fail_count++;
        end

        // Test 4: Multiple force/release cycles
        force sig = 8'h11;
        #1;
        release sig;
        sig = 8'h22;
        #1;
        force sig = 8'h33;
        #1;
        if (sig == 8'h33) begin
            $display("Test 4 PASS: multiple cycles work");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %02h", sig);
            fail_count++;
        end
        release sig;

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
