/*
:name: test_force_sequence
:description: force/release ordering
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_sequence.expected
*/
// IEEE 1800-2023 §10.6.2: force/release ordering
module test_force_sequence;
    logic [7:0] a, b;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Force then immediately release
        a = 8'h00;
        force a = 8'hAA;
        release a;
        a = 8'hBB;
        #1;
        if (a == 8'hBB) begin
            $display("Test 1 PASS: immediate release works, a=%02h", a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: a=%02h", a);
            fail_count++;
        end

        // Test 2: Multiple forces on same signal
        force a = 8'h11;
        force a = 8'h22;
        force a = 8'h33;
        #1;
        if (a == 8'h33) begin
            $display("Test 2 PASS: last force wins, a=%02h", a);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: a=%02h", a);
            fail_count++;
        end
        release a;

        // Test 3: Force after normal assignment
        a = 8'hDD;
        b = 8'hEE;
        force a = 8'hFF;
        #1;
        if (a == 8'hFF && b == 8'hEE) begin
            $display("Test 3 PASS: force after assign");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: a=%02h b=%02h", a, b);
            fail_count++;
        end
        release a;

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
