use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Yxes::Catalyst::Authentication::Credential::Google',
    AUTHOR              => q{Stephen D. Wells <yxes@cpan.org>},
    VERSION_FROM        => 'lib/Yxes/Catalyst/Authentication/Credential/Google.pm',
    ABSTRACT_FROM       => 'lib/Yxes/Catalyst/Authentication/Credential/Google.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	'Moose' 	        	 => '2.0602',
	'MooseX::Types::Moose' 		 => '0.27',
	'LWP::UserAgent'        	 => '6.02',
	'URI'		       		 => '1.60',
	'Catalyst::Runtime'    		 => '5.90015', # to get Catalyst::Exception
	'HTTP::Request::Common'		 => '6.00',    # to get Net::OAuth::Client
	'JSON'				 => '2.53',

        # TEST LIBRARIES - TEST_REQUIRES failed for me :(
        'Test::More'	        	 => '0.98',
	'Test::WWW::Mechanize::Catalyst' => '0.54',
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Yxes-Catalyst-Authentication-Credential-Google-*' },
);
