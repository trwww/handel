#!perl -wT
# $Id$
use strict;
use warnings;
use Test::More tests => 24;

BEGIN {
    use_ok('Handel::Currency');
    use_ok('Handel::Exception', ':try');
};

## test stringification and returns in the absence of
## Locale::Currency::Format
{
    my $currency = Handel::Currency->new(1.2);
    isa_ok($currency, 'Handel::Currency');
    is($currency, 1.2);


    eval 'use Locale::Currency::Format';
    if ($@) {
        is($currency->format, 1.2);
        is($currency->format('CAD'), 1.2);
        is($currency->format(undef, 'FMT_NAME'), 1.2);
        is($currency->format('CAD', 'FMT_NAME'), 1.2);
    } else {
        is($currency->format, '1.20 USD');
        is($currency->format('CAD'), '1.20 CAD');
        is($currency->format(undef, 'FMT_NAME'), '1.20 US Dollar');
        is($currency->format('CAD', 'FMT_NAME'), '1.20 Canadian Dollar');
    };
};


SKIP: {
    eval 'use Finance::Currency::Convert::WebserviceX 0.03';
    skip 'Finance::Currency::Convert::WebserviceX 0.03 not installed', 8 if $@;

    my $currency = Handel::Currency->new(1);
    isa_ok($currency, 'Handel::Currency');
    is($currency, 1);

    try {
        $currency->convert('CRAP', 'CAD');
    } catch Handel::Exception::Argument with {
        pass;
    } otherwise {
        fail;
    };

    try {
        $currency->convert('USD', 'JUNK');
    } catch Handel::Exception::Argument with {
        pass;
    } otherwise {
        fail;
    };

    is($currency->convert('USD', 'USD'), undef);
    ok($currency->convert('USD', 'CAD'));

    {
        local $ENV{'HandelCurrencyCode'} = 'CAD';
        is($currency->convert(undef, 'CAD'), undef);
        ok($currency->convert(undef, 'USD'));
    }
};

SKIP: {
    eval 'use Locale::Currency';
    skip 'Locale::Currency not installed', 4 if $@;

    my $currency = Handel::Currency->new(1);
    isa_ok($currency, 'Handel::Currency');
    is($currency, 1);

    try {
        $currency->convert('ZZZ', 'CAD');
    } catch Handel::Exception::Argument with {
        pass;
    } otherwise {
        fail;
    };

    try {
        $currency->convert('USD', 'ZZZ');
    } catch Handel::Exception::Argument with {
        pass;
    } otherwise {
        fail;
    };
};

SKIP: {
    eval 'use Locale::Currency';
    eval 'use Finance::Currency::Convert::WebserviceX 0.03' if !$@;
    eval 'use Locale::Currency::Format' if !$@;
    skip 'Format and Convert not installed', 4 if $@;

    my $currency = Handel::Currency->new(1.23);
    isa_ok($currency, 'Handel::Currency');
    is($currency, 1.23);

    ok($currency->convert('USD', 'CAD', 1, 'FMT_STANDARD') =~ / CAD$/);
    ok($currency->convert('USD', 'CAD', 0, 'FMT_STANDARD') !~ / CAD$/);
};