/*
:name: test_force_release_wire
:description: force and release on wires
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_release_wire.expected
*/
// IEEE 1800-2023 §10.6.2: force and release on wires
module test_force_release_wire;
    wire [7:0] w;
    logic [7:0] driver;
    int pass_count = 0;
    int fail_count = 0;

    assign w = driver;

    initial begin
        // Test 1: Wire without force follows driver
        driver = 8'h55;
        #1;
        if (w == 8'h55) begin
            $display("Test 1 PASS: wire follows driver=%02h", w);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: expected 55, got %02h", w);
            fail_count++;
        end

        // Test 2: Force wire
        force w = 8'hAA;
        #1;
        if (w == 8'hAA) begin
            $display("Test 2 PASS: wire forced=%02h", w);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: expected AA, got %02h", w);
            fail_count++;
        end

        // Test 3: Re-force with different value
        release w;
        force w = 8'hBB;
        #1;
        if (w == 8'hBB) begin
            $display("Test 3 PASS: re-force works, w=%02h", w);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: expected BB, got %02h", w);
            fail_count++;
        end

        // Test 4: Release returns to driver
        release w;
        driver = 8'h00;
        #1;
        if (w == 8'h00) begin
            $display("Test 4 PASS: release returns to driver=%02h", w);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: expected 00, got %02h", w);
            fail_count++;
        end

        $display("Passed: %0d/4", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
