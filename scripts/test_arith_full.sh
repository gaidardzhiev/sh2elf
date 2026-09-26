#!/bin/sh
A=7
B=3
echo $(( A * B + 2 ))
echo $(( (A + B) * 2 ))
echo $(( A ** 2 ))
echo $(( A % B )) $(( A / B )) $(( -A / B ))
echo $(( A << 2 )) $(( A >> 1 )) $(( A & B )) $(( A | B )) $(( A ^ B )) $(( ~A ))
echo $(( A > B )) $(( A <= B )) $(( A == 7 )) $(( A != 7 ))
echo $(( A > B && B > 5 )) $(( A > B || B > 5 )) $(( !A ))
echo $(( A > B ? A : B ))
echo $(( 0x1F )) $(( 017 )) $(( 2#1011 )) $(( 16#ff ))
echo $(( C = A + B )) $C
echo $(( C += 5 )) $C
echo $(( C++ )) $C $(( ++C )) $C
echo $(( C-- )) $(( --C )) $C
echo "$(( A * (B + 1) ))"
X=A
echo $(( X + 1 ))
echo $(( $A + $B ))
echo $(( 1, 2, A * 100 ))
