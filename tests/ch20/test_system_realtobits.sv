/*
:name: test_system_realtobits
:description: $realtobits conversion
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_realtobits.expected
*/
// $realtobits conversion
module test_realtobits;
    real real_val;
    reg [63:0] bits_val;

    initial begin
        // Test 1: Convert 0.0 to bits
        real_val = 0.0;
        bits_val = $realtobits(real_val);
        if (bits_val == 64'h0000000000000000) begin
            $display("PASS: Test 1 - $realtobits(0.0) = %h", bits_val);
        end else begin
            $display("FAIL: Test 1 - Expected 0, got %h", bits_val);
        end

        // Test 2: Convert 1.0 to bits (IEEE 754: 0x3FF0000000000000)
        real_val = 1.0;
        bits_val = $realtobits(real_val);
        if (bits_val == 64'h3FF0000000000000) begin
            $display("PASS: Test 2 - $realtobits(1.0) = %h", bits_val);
        end else begin
            $display("FAIL: Test 2 - Expected 3FF0000000000000, got %h", bits_val);
        end

        // Test 3: Convert -1.0 to bits (IEEE 754: 0xBFF0000000000000)
        real_val = -1.0;
        bits_val = $realtobits(real_val);
        if (bits_val == 64'hBFF0000000000000) begin
            $display("PASS: Test 3 - $realtobits(-1.0) = %h", bits_val);
        end else begin
            $display("FAIL: Test 3 - Expected BFF0000000000000, got %h", bits_val);
        end

        // Test 4: Convert 2.0 to bits (IEEE 754: 0x4000000000000000)
        real_val = 2.0;
        bits_val = $realtobits(real_val);
        if (bits_val == 64'h4000000000000000) begin
            $display("PASS: Test 4 - $realtobits(2.0) = %h", bits_val);
        end else begin
            $display("FAIL: Test 4 - Expected 4000000000000000, got %h", bits_val);
        end

        // Test 5: Convert 0.5 to bits (IEEE 754: 0x3FE0000000000000)
        real_val = 0.5;
        bits_val = $realtobits(real_val);
        if (bits_val == 64'h3FE0000000000000) begin
            $display("PASS: Test 5 - $realtobits(0.5) = %h", bits_val);
        end else begin
            $display("FAIL: Test 5 - Expected 3FE0000000000000, got %h", bits_val);
        end

        $finish;
    end
endmodule
