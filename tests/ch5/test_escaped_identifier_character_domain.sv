/*
:name: test_escaped_identifier_character_domain
:description: Every printable ASCII character from 33 through 126, with number sign inside a longer name, can appear in an escaped identifier, as can the multi-character names of the standard's examples and an escaped keyword (IEEE 1800-2023 Section 5.6.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_escaped_identifier_character_domain.expected
*/
// IEEE 1800-2023 §5.6.1: an escaped identifier starts with a backslash, ends
// with white space, and may contain any printable ASCII character except
// white space (decimal 33 through 126). The backslash and the terminating
// white space are not part of the name (B003). Each variable below has a
// one-character escaped name for a value in that range and is assigned its own
// code, so a character outside the domain or a character that ends the name
// early changes the compiled design or the printed line. The number sign is
// covered inside \a#b, and the last group uses multi-character names from the
// examples of B005 and the escaped keyword \net, which is a user-defined
// identifier. Icarus Verilog 13.0 misreads the one-character name \# as a
// special name, so the number sign is exercised inside \a#b instead.

module test_escaped_identifier_character_domain;
  logic [7:0] \! ;
  logic [7:0] \" ;
  logic [7:0] \$ ;
  logic [7:0] \% ;
  logic [7:0] \& ;
  logic [7:0] \' ;
  logic [7:0] \( ;
  logic [7:0] \) ;
  logic [7:0] \* ;
  logic [7:0] \+ ;
  logic [7:0] \, ;
  logic [7:0] \- ;
  logic [7:0] \. ;
  logic [7:0] \/ ;
  logic [7:0] \0 ;
  logic [7:0] \1 ;
  logic [7:0] \2 ;
  logic [7:0] \3 ;
  logic [7:0] \4 ;
  logic [7:0] \5 ;
  logic [7:0] \6 ;
  logic [7:0] \7 ;
  logic [7:0] \8 ;
  logic [7:0] \9 ;
  logic [7:0] \: ;
  logic [7:0] \; ;
  logic [7:0] \< ;
  logic [7:0] \= ;
  logic [7:0] \> ;
  logic [7:0] \? ;
  logic [7:0] \@ ;
  logic [7:0] \A ;
  logic [7:0] \B ;
  logic [7:0] \C ;
  logic [7:0] \D ;
  logic [7:0] \E ;
  logic [7:0] \F ;
  logic [7:0] \G ;
  logic [7:0] \H ;
  logic [7:0] \I ;
  logic [7:0] \J ;
  logic [7:0] \K ;
  logic [7:0] \L ;
  logic [7:0] \M ;
  logic [7:0] \N ;
  logic [7:0] \O ;
  logic [7:0] \P ;
  logic [7:0] \Q ;
  logic [7:0] \R ;
  logic [7:0] \S ;
  logic [7:0] \T ;
  logic [7:0] \U ;
  logic [7:0] \V ;
  logic [7:0] \W ;
  logic [7:0] \X ;
  logic [7:0] \Y ;
  logic [7:0] \Z ;
  logic [7:0] \[ ;
  logic [7:0] \\ ;
  logic [7:0] \] ;
  logic [7:0] \^ ;
  logic [7:0] \_ ;
  logic [7:0] \` ;
  logic [7:0] \a ;
  logic [7:0] \b ;
  logic [7:0] \c ;
  logic [7:0] \d ;
  logic [7:0] \e ;
  logic [7:0] \f ;
  logic [7:0] \g ;
  logic [7:0] \h ;
  logic [7:0] \i ;
  logic [7:0] \j ;
  logic [7:0] \k ;
  logic [7:0] \l ;
  logic [7:0] \m ;
  logic [7:0] \n ;
  logic [7:0] \o ;
  logic [7:0] \p ;
  logic [7:0] \q ;
  logic [7:0] \r ;
  logic [7:0] \s ;
  logic [7:0] \t ;
  logic [7:0] \u ;
  logic [7:0] \v ;
  logic [7:0] \w ;
  logic [7:0] \x ;
  logic [7:0] \y ;
  logic [7:0] \z ;
  logic [7:0] \{ ;
  logic [7:0] \| ;
  logic [7:0] \} ;
  logic [7:0] \~ ;
  logic [7:0] \busa+index ;
  logic [7:0] \-clock ;
  logic [7:0] \***error-condition*** ;
  logic [7:0] \a*(b+c) ;
  logic [7:0] \{a,b} ;
  logic [7:0] \net ;
  logic [7:0] \a#b ;

  initial begin
    \! = 8'd33;
    \" = 8'd34;
    \$ = 8'd36;
    \% = 8'd37;
    \& = 8'd38;
    \' = 8'd39;
    \( = 8'd40;
    \) = 8'd41;
    \* = 8'd42;
    \+ = 8'd43;
    \, = 8'd44;
    \- = 8'd45;
    \. = 8'd46;
    \/ = 8'd47;
    \0 = 8'd48;
    \1 = 8'd49;
    \2 = 8'd50;
    \3 = 8'd51;
    \4 = 8'd52;
    \5 = 8'd53;
    \6 = 8'd54;
    \7 = 8'd55;
    \8 = 8'd56;
    \9 = 8'd57;
    \: = 8'd58;
    \; = 8'd59;
    \< = 8'd60;
    \= = 8'd61;
    \> = 8'd62;
    \? = 8'd63;
    \@ = 8'd64;
    \A = 8'd65;
    \B = 8'd66;
    \C = 8'd67;
    \D = 8'd68;
    \E = 8'd69;
    \F = 8'd70;
    \G = 8'd71;
    \H = 8'd72;
    \I = 8'd73;
    \J = 8'd74;
    \K = 8'd75;
    \L = 8'd76;
    \M = 8'd77;
    \N = 8'd78;
    \O = 8'd79;
    \P = 8'd80;
    \Q = 8'd81;
    \R = 8'd82;
    \S = 8'd83;
    \T = 8'd84;
    \U = 8'd85;
    \V = 8'd86;
    \W = 8'd87;
    \X = 8'd88;
    \Y = 8'd89;
    \Z = 8'd90;
    \[ = 8'd91;
    \\ = 8'd92;
    \] = 8'd93;
    \^ = 8'd94;
    \_ = 8'd95;
    \` = 8'd96;
    \a = 8'd97;
    \b = 8'd98;
    \c = 8'd99;
    \d = 8'd100;
    \e = 8'd101;
    \f = 8'd102;
    \g = 8'd103;
    \h = 8'd104;
    \i = 8'd105;
    \j = 8'd106;
    \k = 8'd107;
    \l = 8'd108;
    \m = 8'd109;
    \n = 8'd110;
    \o = 8'd111;
    \p = 8'd112;
    \q = 8'd113;
    \r = 8'd114;
    \s = 8'd115;
    \t = 8'd116;
    \u = 8'd117;
    \v = 8'd118;
    \w = 8'd119;
    \x = 8'd120;
    \y = 8'd121;
    \z = 8'd122;
    \{ = 8'd123;
    \| = 8'd124;
    \} = 8'd125;
    \~ = 8'd126;
    \busa+index = 8'd1;
    \-clock = 8'd2;
    \***error-condition*** = 8'd3;
    \a*(b+c) = 8'd4;
    \{a,b} = 8'd5;
    \net = 8'd6;
    \a#b = 8'd7;
    #1;
    $display("%s", { \! , \" , \$ , \% , \& , \' , \( , \) , \* , \+ });
    $display("%s", { \, , \- , \. , \/ , \0 , \1 , \2 , \3 , \4 , \5 });
    $display("%s", { \6 , \7 , \8 , \9 , \: , \; , \< , \= , \> , \? });
    $display("%s", { \@ , \A , \B , \C , \D , \E , \F , \G , \H , \I });
    $display("%s", { \J , \K , \L , \M , \N , \O , \P , \Q , \R , \S });
    $display("%s", { \T , \U , \V , \W , \X , \Y , \Z , \[ , \\ , \] });
    $display("%s", { \^ , \_ , \` , \a , \b , \c , \d , \e , \f , \g });
    $display("%s", { \h , \i , \j , \k , \l , \m , \n , \o , \p , \q });
    $display("%s", { \r , \s , \t , \u , \v , \w , \x , \y , \z , \{ });
    $display("%s", { \| , \} , \~ });
    $display("multi=%0d %0d %0d %0d %0d %0d %0d",
             \busa+index , \-clock , \***error-condition*** , \a*(b+c) ,
             \{a,b} , \net , \a#b );
  end
endmodule
