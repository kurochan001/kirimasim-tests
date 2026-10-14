/*
:name: test_type_casting
:description: Corner Case: Type Casting
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.1 10.7 11.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_casting.expected
*/
// Corner Case: Type Casting
// Tests various type cast scenarios

module test_type_casting;
    int test_count;
    int pass_count;

    logic [31:0] logic32;
    int signed_int;
    real r;
    shortreal sr;
    logic [7:0] byte_val;
    logic [63:0] logic64;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: int to logic
        signed_int = -100;
        logic32 = signed_int;
        test_count++;
        if ($signed(logic32) == -100) pass_count++;
        else $display("FAIL: int to logic - value=%0d", $signed(logic32));

        // Test 2: logic to int
        logic32 = 32'hFFFFFF00;
        signed_int = logic32;
        test_count++;
        if (signed_int == -256) pass_count++;
        else $display("FAIL: logic to int - value=%0d", signed_int);

        // Test 3: real to int (truncation)
        r = 123.99;
        signed_int = int'(r);
        test_count++;
        // int'() rounds to the nearest integer (6.12.1)
        if (signed_int == 124) pass_count++;
        else $display("FAIL: real to int - value=%0d", signed_int);

        // Test 4: int to real
        signed_int = 42;
        r = real'(signed_int);
        test_count++;
        if (r > 41.9 && r < 42.1) pass_count++;
        else $display("FAIL: int to real - value=%f", r);

        // Test 5: Narrowing cast
        logic32 = 32'h12345678;
        byte_val = logic32[7:0];
        test_count++;
        if (byte_val == 8'h78) pass_count++;
        else $display("FAIL: Narrowing - value=0x%0h", byte_val);

        // Test 6: Widening cast
        byte_val = 8'hAB;
        logic32 = {24'h0, byte_val};
        test_count++;
        if (logic32 == 32'h000000AB) pass_count++;
        else $display("FAIL: Widening - value=0x%0h", logic32);

        // Test 7: Static cast syntax
        r = 3.14;
        signed_int = int'(r * 100);
        test_count++;
        if (signed_int == 314) pass_count++;
        else $display("FAIL: Static cast - value=%0d", signed_int);

        // Test 8: Signed cast
        byte_val = 8'hFF;  // 255 unsigned or -1 signed
        signed_int = $signed(byte_val);
        test_count++;
        if (signed_int == -1) pass_count++;
        else $display("FAIL: Signed cast - value=%0d", signed_int);

        $display("Corner Case Type Casting: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
