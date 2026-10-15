/*
:name: test_member_ext
:description: Test 1: Packed struct write
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 8.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_ext.expected
*/
// IEEE 1800-2023 §7.2, §8

module test_member_ext;
    typedef struct packed {
        logic [7:0] header;
        logic [15:0] data;
        logic [7:0] footer;
    } packet_t;

    typedef struct {
        int x;
        int y;
        int z;
    } point_t;

    class MyClass;
        int value;
        string name;
        function new(int v, string n);
            value = v;
            name = n;
        endfunction
        function int get_value();
            return value;
        endfunction
    endclass

    packet_t pkt;
    point_t pt;
    MyClass obj;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Packed struct write
        test_count++;
        pkt.header = 8'hAA;
        pkt.data = 16'hBBCC;
        pkt.footer = 8'hDD;
        if (pkt.header == 8'hAA) begin
            $display("Test 1: Packed write PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Packed struct read
        test_count++;
        if (pkt.data == 16'hBBCC && pkt.footer == 8'hDD) begin
            $display("Test 2: Packed read PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Unpacked struct
        test_count++;
        pt.x = 10;
        pt.y = 20;
        pt.z = 30;
        if (pt.x == 10 && pt.y == 20) begin
            $display("Test 3: Unpacked struct PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Class member
        test_count++;
        obj = new(42, "test");
        if (obj.value == 42) begin
            $display("Test 4: Class member PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Class method
        test_count++;
        if (obj.get_value() == 42) begin
            $display("Test 5: Class method PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: String member
        test_count++;
        if (obj.name == "test") begin
            $display("Test 6: String member PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
        end

        // Test 7: Member in expression
        test_count++;
        if (pt.x + pt.y + pt.z == 60) begin
            $display("Test 7: Member expr PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL");
        end

        // Test 8: Modify class member
        test_count++;
        obj.value = 100;
        if (obj.get_value() == 100) begin
            $display("Test 8: Modify member PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
