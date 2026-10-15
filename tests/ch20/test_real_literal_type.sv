/*
:name: test_real_literal_type
:description: Real literals given to $shortrealtobits and $realtobits
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 5.7.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_real_literal_type.expected
*/
// IEEE 1800-2023: Test real literal type preservation
// Real literals passed to the conversion functions keep their real value

module test_real_literal_type;
    initial begin
        shortreal x;
        real y;
        bit [31:0] bits;
        bit [63:0] bits64;

        $display("=== Real Literal Type Preservation Test ===\n");

        // Test 1: Direct shortreal literal conversion
        $display("Test 1: Direct literal conversion");
        bits = $shortrealtobits(1.5);
        $display("  $shortrealtobits(1.5) = 0x%h", bits);
        assert(bits == 32'h3fc00000) else $display("FAIL: Direct literal conversion");
        $display("  PASS\n");

        // Test 2: Variable assignment then conversion
        $display("Test 2: Variable assignment");
        x = 2.5;
        bits = $shortrealtobits(x);
        $display("  x = 2.5; $shortrealtobits(x) = 0x%h", bits);
        assert(bits == 32'h40200000) else $display("FAIL: Variable conversion");
        $display("  PASS\n");

        // Test 3: Real (64-bit) literal
        $display("Test 3: Real (64-bit) literal");
        bits64 = $realtobits(3.14159265358979323846);
        $display("  $realtobits(pi) = 0x%h", bits64);
        // IEEE 754 double precision for pi
        assert(bits64 == 64'h400921fb54442d18) else $display("FAIL: Real literal conversion");
        $display("  PASS\n");

        // Test 4: Negative real literal
        $display("Test 4: Negative literal");
        bits = $shortrealtobits(-0.5);
        $display("  $shortrealtobits(-0.5) = 0x%h", bits);
        assert(bits == 32'hbf000000) else $display("FAIL: Negative literal");
        $display("  PASS\n");

        // Test 5: Very small literal
        $display("Test 5: Small literal");
        bits = $shortrealtobits(0.0001);
        $display("  $shortrealtobits(0.0001) = 0x%h", bits);
        // 0.0001 in IEEE 754 single precision
        assert(bits == 32'h38d1b717) else $display("FAIL: Small literal, got 0x%h", bits);
        $display("  PASS\n");

        $display("=== All Real Literal Tests PASSED ===");
        $finish;
    end
endmodule
