/*
:name: test_force_xz
:description: force with X and Z values
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_force_xz.expected
*/
// IEEE 1800-2023 §10.6.2: force with X and Z values
module test_force_xz;
    logic [7:0] sig;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Force with X value
        sig = 8'h00;
        force sig = 8'bxxxx_xxxx;
        #1;
        if (sig === 8'bxxxx_xxxx) begin
            $display("Test 1 PASS: force X value");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: expected X, got %b", sig);
            fail_count++;
        end
        release sig;

        // Test 2: Force with Z value
        sig = 8'hFF;
        force sig = 8'bzzzz_zzzz;
        #1;
        if (sig === 8'bzzzz_zzzz) begin
            $display("Test 2 PASS: force Z value");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: expected Z, got %b", sig);
            fail_count++;
        end
        release sig;

        // Test 3: Force with mixed X/Z/0/1
        sig = 8'h00;
        force sig = 8'b10xz_01zx;
        #1;
        if (sig === 8'b10xz_01zx) begin
            $display("Test 3 PASS: force mixed value");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %b", sig);
            fail_count++;
        end
        release sig;

        // Test 4: Release restores normal assignment
        sig = 8'hAB;
        #1;
        if (sig == 8'hAB) begin
            $display("Test 4 PASS: normal value after XZ release, sig=%02h", sig);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %02h", sig);
            fail_count++;
        end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
