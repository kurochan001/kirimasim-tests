/*
:name: test_assign_struct
:description: Test for struct assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_struct.expected
*/
// Test for struct assignment
// IEEE 1800-2023 §7.2: Structures
module test_assign_struct;
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } pair_t;

    typedef struct {
        int x;
        int y;
        string name;
    } point_t;

    int fails = 0;


    initial begin
        pair_t p1, p2;
        point_t pt1, pt2;

        // Packed struct assignment
        p1.a = 8'hAA;
        p1.b = 8'hBB;
        p2 = p1;
        if (p2.a != 8'hAA) begin fails++; $display("FAIL: Packed struct copy a"); end
        if (p2.b != 8'hBB) begin fails++; $display("FAIL: Packed struct copy b"); end

        // Packed struct literal
        p1 = '{8'h11, 8'h22};
        if (p1.a != 8'h11) begin fails++; $display("FAIL: Packed literal a"); end

        // Unpacked struct
        pt1.x = 10;
        pt1.y = 20;
        pt1.name = "Point1";
        pt2 = pt1;
        if (pt2.x != 10) begin fails++; $display("FAIL: Unpacked struct x"); end
        if (pt2.name != "Point1") begin fails++; $display("FAIL: Unpacked struct name"); end

        // Member modification
        pt2.x = 30;
        if (pt1.x != 10) begin fails++; $display("FAIL: Original unchanged"); end

        if (fails == 0) $display("PASS: Struct assignment");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
