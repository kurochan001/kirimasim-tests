/*
:name: test_assign_shift
:description: Shift assignments
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_shift.expected
*/
// IEEE 1800-2023 §10.4: Shift assignments
module test_assign_shift;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] a;

    initial begin
        // Test 1: Left shift
        a = 8'h01;
        a = a << 4;
        if (a == 8'h10) begin
            $display("Test 1 PASS: lshift = %02h", a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", a);
            fail_count++;
        end

        // Test 2: Right shift
        a = 8'h80;
        a = a >> 4;
        if (a == 8'h08) begin
            $display("Test 2 PASS: rshift = %02h", a);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", a);
            fail_count++;
        end

        // Test 3: Left shift by 0 (no-op)
        a = 8'hAB;
        a = a << 0;
        if (a == 8'hAB) begin
            $display("Test 3 PASS: shift 0 = %02h", a);
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
