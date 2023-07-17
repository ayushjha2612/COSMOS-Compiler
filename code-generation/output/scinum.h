#include <iostream>
#include <math.h>
using namespace std;

class SN
{
private:
    float number;
    short int power;

public:
    SN(float num, short int pow)
    {
        number = num;
        power = pow;
        cleanse();
    }
    SN()
    {
        number = 1.0;
        power = 0;
    };
    SN operator^(SN obj)
    {
        SN result;
        cleanse();
        obj.cleanse();
        if (obj.power >= 2)
        {
            if (number > 1)
            {
                result.number = 9.9999;
                result.power = 32767;
            }
            else
            {
                result.number = 0.0;
                result.power = 0;
            }
        }
        else if (obj.power <= -2)
        {
            if (number > 1)
            {
                result.number = 0.0;
                result.power = 0;
            }
            else
            {
                result.number = 9.99;
                result.power = 32767;
            }
        }
        else
        {
            float powr = obj.number * pow(10, obj.power);
            result.number = pow(number, powr);
            result.power = power * powr;
        }
        result.cleanse();
        return result;
    }
    SN operator*(SN const &obj)
    {
        SN result;
        cleanse();
        result.number = number * (obj.number);
        result.power = power + obj.power;
        result.cleanse();
        return result;
    }
    SN operator/(SN const &obj)
    {
        SN result;
        cleanse();
        result.number = number / (obj.number);
        result.power = power - obj.power;
        result.cleanse();
        return result;
    }
    SN operator+(SN obj)
    {
        SN result;
        cleanse();
        obj.cleanse();
        short int maxp = max(obj.power, power);
        short int minp = min(power, obj.power);

        if (maxp - minp <= 5)
        {
            if (maxp == power)
            {
                result.number = number + (obj.number / pow(10, (maxp - minp)));
                result.power = power;
            }
            else
            {
                result.number = (number / pow(10, (maxp - minp))) + (obj.number);
                result.power = obj.power;
            }
        }
        else
        {
            if (maxp == power)
            {
                result.power = power;
                result.number = number;
            }
            else
            {
                result.power = obj.power;
                result.number = obj.number;
            }
        }

        result.cleanse();
        return result;
    }
    SN operator-(SN obj)
    {
        SN result;
        cleanse();
        obj.cleanse();
        short int maxp = max(obj.power, power);
        short int minp = min(power, obj.power);

        if (maxp - minp <= 5)
        {
            if (maxp == power)
            {
                result.number = number - (obj.number / pow(10, (maxp - minp)));
                result.power = power;
            }
            else
            {
                result.number = (number / pow(10, (maxp - minp))) - (obj.number);
                result.power = obj.power;
            }
        }
        else
        {
            if (maxp == power)
            {
                result.power = power;
                result.number = number;
            }
            else
            {
                result.power = obj.power;
                result.number = obj.number;
            }
        }
        result.cleanse();
        return result;
    }
    bool operator>(SN obj)
    {
        cleanse();
        obj.cleanse();
        if (obj.power != power)
        {
            return power > obj.power;
        }
        else
        {
            return number > obj.number;
        }
    }
    bool operator<(SN obj)
    {
        cleanse();
        obj.cleanse();
        if (obj.power != power)
        {
            return power < obj.power;
        }
        else
        {
            return number < obj.number;
        }
    }
    bool operator>=(SN obj)
    {
        cleanse();
        obj.cleanse();
        if (obj.power != power)
        {
            return power >= obj.power;
        }
        else
        {
            return number >= obj.number;
        }
    }
    bool operator<=(SN obj)
    {
        cleanse();
        obj.cleanse();
        if (obj.power != power)
        {
            return power <= obj.power;
        }
        else
        {
            return number <= obj.number;
        }
    }
    bool operator!=(SN obj)
    {
        cleanse();
        obj.cleanse();
        if (obj.power == power && number == obj.number)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    bool operator==(SN obj)
    {
        cleanse();
        obj.cleanse();
        if (obj.power == power && number == obj.number)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    void cleanse()
    {
        if (number == 0.0)
        {
            return;
        }
        while (number >= 10)
        {
            this->number /= 10;
            this->power += 1;
        }
        while (number < 1)
        {
            this->number *= 10;
            this->power -= 1;
        }
    }
    void init(float num, short int pow)
    {
        this->number = num;
        this->power = pow;
    }
    string print()
    {
        string result = to_string(number) + "e" + to_string(power);
        return result;
    }
};

typedef SN acc;
typedef SN arcsec;
typedef SN au;
typedef SN density;
typedef SN dist;
typedef SN energy;
typedef SN force;
typedef SN freq;
typedef SN ly;
typedef SN mass;
typedef SN parsec;
typedef SN solar_mass;
typedef SN speed;
typedef SN temp;
typedef SN Time;

void initSN(SN &a, string s)
{
    int ind = s.find("e");
    float f = stof(s.substr(0, ind));
    short int si = stoi(s.substr(ind + 1));

    a.init(f, si);
}