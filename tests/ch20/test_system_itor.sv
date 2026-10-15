/*
:name: test_system_itor
:description: $itor integer to real conversion
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_itor.expected
*/
// $itor integer to real conversion
module test_itor;
    integer int_val;
    real real_val;
    reg [31:0] unsigned_val;
    reg signed [31:0] signed_val;

    initial begin
        // Test 1: Convert positive integer
        int_val = 42;
        real_val = $itor(int_val);
        if (real_val == 42.0) begin
            $display("PASS: Test 1 - $itor(42) = %f", real_val);
        end else begin
            $display("FAIL: Test 1 - Expected 42.0, got %f", real_val);
        end

        // Test 2: Convert zero
        int_val = 0;
        real_val = $itor(int_val);
        if (real_val == 0.0) begin
            $display("PASS: Test 2 - $itor(0) = %f", real_val);
        end else begin
            $display("FAIL: Test 2 - Expected 0.0, got %f", real_val);
        end

        // Test 3: Convert negative integer
        int_val = -100;
        real_val = $itor(int_val);
        if (real_val == -100.0) begin
            $display("PASS: Test 3 - $itor(-100) = %f", real_val);
        end else begin
            $display("FAIL: Test 3 - Expected -100.0, got %f", real_val);
        end

        // Test 4: Convert large positive integer
        int_val = 1000000;
        real_val = $itor(int_val);
        if (real_val == 1000000.0) begin
            $display("PASS: Test 4 - $itor(1000000) = %f", real_val);
        end else begin
            $display("FAIL: Test 4 - Expected 1000000.0, got %f", real_val);
        end

        // Test 5: Convert signed reg
        signed_val = -500;
        real_val = $itor(signed_val);
        if (real_val == -500.0) begin
            $display("PASS: Test 5 - $itor(signed -500) = %f", real_val);
        end else begin
            $display("FAIL: Test 5 - Expected -500.0, got %f", real_val);
        end

        $finish;
    end
endmodule
