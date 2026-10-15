/*
:name: test_system_bitstoreal
:description: $bitstoreal conversion
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_bitstoreal.expected
*/
// $bitstoreal conversion
module test_bitstoreal;
    real real_val;
    reg [63:0] bits_val;

    initial begin
        // Test 1: Convert 0x0 to 0.0
        bits_val = 64'h0000000000000000;
        real_val = $bitstoreal(bits_val);
        if (real_val == 0.0) begin
            $display("PASS: Test 1 - $bitstoreal(0x0) = %f", real_val);
        end else begin
            $display("FAIL: Test 1 - Expected 0.0, got %f", real_val);
        end

        // Test 2: Convert IEEE 754 representation of 1.0
        bits_val = 64'h3FF0000000000000;
        real_val = $bitstoreal(bits_val);
        if (real_val == 1.0) begin
            $display("PASS: Test 2 - $bitstoreal(0x3FF...) = %f", real_val);
        end else begin
            $display("FAIL: Test 2 - Expected 1.0, got %f", real_val);
        end

        // Test 3: Convert IEEE 754 representation of -1.0
        bits_val = 64'hBFF0000000000000;
        real_val = $bitstoreal(bits_val);
        if (real_val == -1.0) begin
            $display("PASS: Test 3 - $bitstoreal(0xBFF...) = %f", real_val);
        end else begin
            $display("FAIL: Test 3 - Expected -1.0, got %f", real_val);
        end

        // Test 4: Convert IEEE 754 representation of 2.0
        bits_val = 64'h4000000000000000;
        real_val = $bitstoreal(bits_val);
        if (real_val == 2.0) begin
            $display("PASS: Test 4 - $bitstoreal(0x400...) = %f", real_val);
        end else begin
            $display("FAIL: Test 4 - Expected 2.0, got %f", real_val);
        end

        // Test 5: Round-trip conversion
        bits_val = 64'h400921FB54442D18; // Approximately PI
        real_val = $bitstoreal(bits_val);
        if (real_val > 3.14 && real_val < 3.15) begin
            $display("PASS: Test 5 - $bitstoreal(PI bits) = %f", real_val);
        end else begin
            $display("FAIL: Test 5 - Expected ~3.14159, got %f", real_val);
        end

        $finish;
    end
endmodule
