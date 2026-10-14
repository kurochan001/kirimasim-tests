/*
:name: test_force_2state
:description: force with 2-state types
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_2state.expected
*/
// IEEE 1800-2023 §10.6.2: force with 2-state types
module test_force_2state;
    bit [7:0] b;
    int i;
    byte by;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Force bit vector
        b = 8'h00;
        force b = 8'hAB;
        #1;
        if (b == 8'hAB) begin
            $display("Test 1 PASS: force bit=%02h", b);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: expected AB, got %02h", b);
            fail_count++;
        end
        release b;

        // Test 2: Force int
        i = 0;
        force i = 32'h12345678;
        #1;
        if (i == 32'h12345678) begin
            $display("Test 2 PASS: force int=%08h", i);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", i);
            fail_count++;
        end
        release i;

        // Test 3: Force byte
        by = 0;
        force by = 8'h99;
        #1;
        if (by == 8'h99) begin
            $display("Test 3 PASS: force byte=%02h", by);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", by);
            fail_count++;
        end
        release by;

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
