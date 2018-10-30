-- -*- coding: utf-8 -*-
newPackage(
	"SturmDiscriminants",
	Version => "0.1",
	Date => "October 2018",
	Authors => {{
		  Name => "Alexandru Iosif",
		  Email => "alexandru.iosif@ovgu.de",
		  HomePage => "https://alexandru-iosif.github.io"}},
    	Headline => "Computation of Sturm Discriminants", 
	DebuggingMode => true
)

export {
     -- 'Official' functions
     "SturmDiscriminant"

     -- Not in the interface:
--   "SturmSequence",
--   "numeratorMatrix"
--   "denominatorMatrix"
--   "radicalMatrix"
--   "factorsMatrix"
--   "elementsWithPositiveCoefficients"
--   "elementsWithNegativeCoefficients"
}


SturmSequence = f -> (
-- by Dan Grayson & Frank Sottile:    
     assert( isPolynomialRing ring f );
     assert( numgens ring f === 1 );
     R := ring f;
     assert( char R == 0 );
     x := R_0;
     n := first degree f;
     c := new MutableList from toList (0 .. n);
     if n >= 0 then (
     	  c#0 = f;
          if n >= 1 then (
               c#1 = diff(x,f);
               scan(2 .. n, i -> c#i = - c#(i-2) % c#(i-1));
               ));
     toList c)

-- the following function takes as input a matrix M and returns
-- another matrix whose entries are the numerator of M:
numeratorMatrix = M ->(
    matrix apply(entries M, i -> apply ( i, j -> numerator j) )
    )

-- the following function takes as input a matrix M and returns
-- another matrix whose entries are the denominator of M:
denominatorMatrix = M ->(
    matrix apply(entries M, i -> apply ( i, j -> denominator j) )
    )

-- the following function takes as input a matrix M and returns
-- another matrix whose entries are the the radicals of the entries of
-- M:
radicalMatrix = M ->(
    R := ring M;
    matrix apply(entries M, i -> apply ( i, j ->(flatten entries gens radical ideal j |{1_R})_0))
    )

-- the following function factors the entries of a matrix:
factorsMatrix = M ->(
    R := ring M;
    M = radicalMatrix M;
    factors := toList set flatten apply (entries M, i -> toList set flatten apply ( i, j -> ((toList factor j)|{1_R})) );
    apply( factors , i -> value i )
    )

-- the following function takes as input a list of polynomials and
-- gives as output those polynomials with positive coefficients:
elementsWithPositiveCoefficients = L ->(
    Lpositive := toList (set (flatten apply (L, i -> if (all (flatten entries sub((coefficients (i))#1,QQ), j -> j >= 0 )) then i)) - set{null})
    )

-- the following function takes as input a list of polynomials and
-- gives as output those polynomials with negative coefficients
elementsWithNegativeCoefficients = L ->(
    Lpositive := toList (set (flatten apply (L, i -> if (all (flatten entries sub((coefficients (i))#1,QQ), j -> j <= 0 )) then i)) - set{null})
    )

-- SturmDiscriminant; the ideal I should be an ideal of
-- Rcoef[variables], where Rcoef=ring of coefficients
SturmDiscriminant = I -> (
    R := ring I;
    Rcoef := coefficientRing R;
    assert( dim sub(I,frac(Rcoef)[flatten entries vars R]) == 0 );
    assert( char R == 0 );
    assert( (class Rcoef) =!= FractionField );
    K := frac(Rcoef);
    Rflat := (flattenRing R)#0;
    J := symbol J;
    fgenerator := symbol fgenerator;
    eliminationVariables := symbol eliminationVariables;
    fsturm := symbol fsturm;
    sturmdiscriminant := set {};
    for i from 0 to numgens R - 1 do(
    	eliminationVariables = toList set flatten entries  vars R - set{(flatten entries vars R)_i};
    	eliminationVariables = flatten entries sub(matrix{eliminationVariables},Rflat);
    	J_i = eliminate(sub(I,Rflat),eliminationVariables);
    	assert (numgens J_i == 1);
    	fgenerator = sub((gens J_i)_0_0,K[(vars R)_i_0]);
    	fsturm = SturmSequence fgenerator;
    	sturmdiscriminant = sturmdiscriminant + set factorsMatrix sub(numeratorMatrix sub((coefficients matrix {fsturm})#1,K),Rcoef) + set factorsMatrix sub(denominatorMatrix sub((coefficients matrix {fsturm})#1,K),Rcoef) ;
    	);
    sturmdiscriminant = flatten entries sub (matrix{toList sturmdiscriminant},Rcoef);
    use R;
    sturmdiscriminant = toList (set sturmdiscriminant - set{1_Rcoef}-set flatten entries vars Rcoef);
    toList (set sturmdiscriminant - set elementsWithPositiveCoefficients sturmdiscriminant -set elementsWithNegativeCoefficients sturmdiscriminant)
    )

beginDocumentation()

document {
    Key => SturmDiscriminants,
    Headline => "a package for computing Sturm Discriminants",
    
    EM "SturmDiscriminants", " is a package that makes use of
    Sturm sequences to compute discriminants of systems with
    positive roots",
    }

document {
     Key => {SturmDiscriminant},
     Headline => "Sturm Discriminant",
     Usage => "SturmDiscriminant I",
     Inputs => {
          "I" => { "a zero dimensional ideal of a polynomial ring of
          the form k[parameters][variables], where are the rational
          numbers "} },
     Outputs => {
          {"a list of polynomials in the parameters of I whose zero
          locus divide the positive orthant into cells with constant
          number of positive roots"} },
     EXAMPLE {
          "R = QQ[a,b,c,d,e,f][x,y]",
          "I = ideal (a*x+b*y+c,d*x+e*y+f)",
          "SturmDiscriminant I",
          },
     Caveat => {"This routines does not work if, after eliminiating
     all the variables except one, the resulting ideal is
     non-principal or zero."}}

end

restart
installPackage "SturmDiscriminants"
