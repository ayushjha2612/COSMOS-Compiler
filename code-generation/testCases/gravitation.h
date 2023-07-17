struct astrobject
{
	mass m;
    dist radius;
};

proc acc calulate_g(struct astrobject planet)
{
	acc a = (6.67e-11*(planet.m))/((planet.radius)^2.0e0);
	return a;
}

proc force gravitational_force(mass ma, mass mb, dist r)
{
    force f = (6.67e-11*ma*mb)/((r)^2.0e0);
    return f;
}