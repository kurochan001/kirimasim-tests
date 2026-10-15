/*
:name: test_structs
:description: Chapter 7: Aggregate data types
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_structs.expected
*/
// IEEE 1800-2023 Chapter 7: Aggregate data types
// §7.2 Structures

module test_structs;
    // §7.2.1 Packed structures
    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } word_t;

    // Unpacked structures
    typedef struct {
        int x;
        int y;
        string name;
    } point_t;

    word_t word;
    point_t point;

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Packed struct assignment
        word = 16'hABCD;
        test_count++;
        if (word == 16'hABCD) pass_count++;
        else $display("FAIL: packed struct - word=0x%0h", word);

        // Test 2: Packed struct member access
        test_count++;
        if (word.high == 8'hAB && word.low == 8'hCD) pass_count++;
        else $display("FAIL: packed members - high=0x%0h, low=0x%0h", word.high, word.low);

        // Test 3: Packed struct member write
        word.high = 8'hFF;
        test_count++;
        if (word == 16'hFFCD) pass_count++;
        else $display("FAIL: member write - word=0x%0h", word);

        // Test 4: Unpacked struct initialization
        point.x = 10;
        point.y = 20;
        point.name = "origin";
        test_count++;
        if (point.x == 10 && point.y == 20) pass_count++;
        else $display("FAIL: unpacked init - x=%0d, y=%0d", point.x, point.y);

        // Test 5: Unpacked struct string member
        test_count++;
        if (point.name == "origin") pass_count++;
        else $display("FAIL: string member - name=%s", point.name);

        // Test 6: Struct member arithmetic
        point.x = point.x + point.y;
        test_count++;
        if (point.x == 30) pass_count++;
        else $display("FAIL: member arithmetic - x=%0d", point.x);

        $display("Chapter 7.2 Structures: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
