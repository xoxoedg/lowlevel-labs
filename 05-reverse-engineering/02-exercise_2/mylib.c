int alg(int n)
{
    if (n <= 1)
        return 1;
    return n * alg(n-1);
}

