/*
:name: test_struct_access
:description: Structures
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_access.expected
*/
// IEEE 1800-2023 Section 7.2: Structures
module test_struct_access;
    typedef struct {
        int x;
        int y;
        logic [7:0] data;
    } point_t;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } packed_t;

    point_t pt;
    packed_t pk;
    logic [15:0] pk_bits;

    int fails = 0;


    initial begin
        // Unpacked struct assignment
        pt.x = 10;
        pt.y = 20;
        pt.data = 8'hAB;

        if (pt.x == 10)
            $display("PASS: pt.x = 10");
        else
            begin fails++; $display("FAIL: pt.x = %0d", pt.x); end

        if (pt.y == 20)
            $display("PASS: pt.y = 20");
        else
            begin fails++; $display("FAIL: pt.y = %0d", pt.y); end

        if (pt.data == 8'hAB)
            $display("PASS: pt.data = 0xAB");
        else
            begin fails++; $display("FAIL: pt.data = 0x%h", pt.data); end

        // Aggregate assignment
        pt = '{30, 40, 8'hCD};
        if (pt.x == 30 && pt.y == 40)
            $display("PASS: aggregate assignment");
        else
            begin fails++; $display("FAIL: aggregate = {%0d, %0d}", pt.x, pt.y); end

        // Packed struct
        pk.a = 8'h12;
        pk.b = 8'h34;
        pk_bits = pk;
        if (pk_bits == 16'h1234)
            $display("PASS: packed struct to bits");
        else
            begin fails++; $display("FAIL: packed = 0x%h", pk_bits); end

        if (fails == 0) $display("TEST PASSED: struct access tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
