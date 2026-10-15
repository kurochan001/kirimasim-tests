/*
:name: test_wildcard_eq
:description: Wildcard equality ==? and inequality !=? with x and z in the right operand
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wildcard_eq.expected
*/
// Wildcard equality ==? and inequality !=? with x and z in the right operand
// IEEE 1800-2023 §11.4.6

module test_wildcard_eq;
    logic [7:0] a, b;
    logic result;

    initial begin
        // Test 1: Wildcard equality - X in right operand is don't care
        a = 8'b1010_0101;
        b = 8'b1010_xxxx;  // X bits in right operand are wildcards

        result = (a ==? b);
        if (result) begin
            $display("TEST1 PASS: wildcard eq with X in pattern");
        end else begin
            $display("TEST1 FAIL: wildcard eq with X in pattern");
        end

        // Test 2: Wildcard equality - Z in right operand is don't care
        a = 8'b1111_0000;
        b = 8'b1111_zzzz;  // Z bits in right operand are wildcards

        result = (a ==? b);
        if (result) begin
            $display("TEST2 PASS: wildcard eq with Z in pattern");
        end else begin
            $display("TEST2 FAIL: wildcard eq with Z in pattern");
        end

        // Test 3: Wildcard inequality
        a = 8'b0000_0000;
        b = 8'b1111_xxxx;  // Must mismatch on upper 4 bits

        result = (a !=? b);
        if (result) begin
            $display("TEST3 PASS: wildcard neq");
        end else begin
            $display("TEST3 FAIL: wildcard neq");
        end

        // Test 4: Exact match (no wildcards)
        a = 8'b1010_1010;
        b = 8'b1010_1010;

        result = (a ==? b);
        if (result) begin
            $display("PASS: wildcard eq");
        end else begin
            $display("FAIL: wildcard eq");
        end

        $finish;
    end
endmodule
