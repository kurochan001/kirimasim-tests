/*
:name: test_countones_2
:description: $countones, $onehot, $onehot0, $isunknown
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_countones_2.expected
*/
// $countones, $onehot, $onehot0, $isunknown
module test_countones;
    reg [7:0] val;
    reg [3:0] val4;
    integer result;
    integer pass_count;

    initial begin
        pass_count = 0;

        // Test 1: $countones
        val = 8'b10101010;
        result = $countones(val);
        if (result == 4) begin
            $display("Test 1: $countones(8'b10101010) = %0d - PASS", result);
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $countones - FAIL (got %0d)", result);
        end

        // Test 2: $onehot (exactly one bit set)
        val = 8'b00001000;
        if ($onehot(val) == 1) begin
            val = 8'b00001010;
            if ($onehot(val) == 0) begin
                $display("Test 2: $onehot - PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("Test 2: $onehot false positive - FAIL");
            end
        end else begin
            $display("Test 2: $onehot true case - FAIL");
        end

        // Test 3: $onehot0 (at most one bit set, including zero)
        val = 8'b00000000;
        if ($onehot0(val) == 1) begin
            val = 8'b00100000;
            if ($onehot0(val) == 1) begin
                val = 8'b00100010;
                if ($onehot0(val) == 0) begin
                    $display("Test 3: $onehot0 - PASS");
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test 3: $onehot0 multi-bit - FAIL");
                end
            end else begin
                $display("Test 3: $onehot0 one-bit - FAIL");
            end
        end else begin
            $display("Test 3: $onehot0 zero - FAIL");
        end

        // Test 4: $isunknown
        val4 = 4'b1010;
        if ($isunknown(val4) == 0) begin
            val4 = 4'b10x0;
            if ($isunknown(val4) == 1) begin
                val4 = 4'b10z0;
                if ($isunknown(val4) == 1) begin
                    $display("Test 4: $isunknown - PASS");
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test 4: $isunknown z - FAIL");
                end
            end else begin
                $display("Test 4: $isunknown x - FAIL");
            end
        end else begin
            $display("Test 4: $isunknown known - FAIL");
        end

        // Test 5: $countones with various patterns
        val = 8'b11111111;
        if ($countones(val) == 8) begin
            val = 8'b00000000;
            if ($countones(val) == 0) begin
                val = 8'b11110000;
                if ($countones(val) == 4) begin
                    $display("Test 5: $countones various - PASS");
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test 5: $countones 11110000 - FAIL");
                end
            end else begin
                $display("Test 5: $countones zeros - FAIL");
            end
        end else begin
            $display("Test 5: $countones all ones - FAIL");
        end

        if (pass_count == 5)
            $display("All countones/onehot tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
