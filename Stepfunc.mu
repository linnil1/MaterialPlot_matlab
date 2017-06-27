// Define main function
Stepfunc := proc(a, x)
begin
    if bool(is(a > 0) = UNKNOWN)
        then procname(args())
    elif bool(a < 0 or x < 0)
        then 0
    else
        a ^ x
    end_if
end_proc:
//Stepfunc(-1,2), (2*Stepfunc(2,3)), Stepfunc(4,0), Stepfunc(x-4,3)
//0, 16, 1, Stepfunc(x - 4, 3)

// extend custom function
Stepfunc := funcenv(Stepfunc):
//3 * Stepfunc(x - 4, 3)
//3*Stepfunc(x-4,3)

// Define integral
Stepfunc::diff := proc(f, x)
local z, a;
begin
    a := op(f)[1];
    z := op(f)[2];
    if z = -1 
        then Stepfunc(a, z + 1)
    else
        Stepfunc(a, z + 1) / (z + 1)
    end_if
end_proc:
// Define integral bcz Mupad ::int is bug
integral := (f, x) -> diff(f, x) :
//integral(3 * Stepfunc(x - 4, -1) + 4 * Stepfunc(x - 1, 5), x)
//3*Stepfunc(x - 4, 0) + (2*Stepfunc(x - 1, 6))/3

// expand
Stepfunc::expand := proc(f)
begin
    expand(op(f)[1] ^ op(f)[2])
end_proc:
//expand(Stepfunc(x - 3, 4))
//x^4 - 12*x^3 + 54*x^2 - 108*x + 81

// plot
//plot(Stepfunc(x - 3, 0))

// ordered
//Stepfunc(x - 3, 4) + Stepfunc(x - 1, 1)
//Stepfunc(x - 1, 1) + Stepfunc(x - 3, 4)