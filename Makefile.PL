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
	'Moose' 	        	   => '2.0602',
	'MooseX::Types::Moose' 		   => '0.27',
	'LWP::UserAgent'        	   => '6.02',
	'URI'		       		   => '1.60',
	'Catalyst::Runtime'    		   => '5.90015', # to get Catalyst::Exception
	'HTTP::Request::Common'		   => '6.00',    # to get Net::OAuth::Client
	'JSON'				   => '2.53',

        # TEST LIBRARIES - TEST_REQUIRES failed for me :(
        'Test::More'	        	   => '0.98',
	'Test::WWW::Mechanize::Catalyst'   => '0.54',
	'MooseX::MarkAsMethods'		   => '0.15',
        'DBIx::Class::Schema'              => 0,
	'Catalyst::Plugin::Authentication' => '0.10023',
	'MooseX::NonMoose'                 => '0.26',
	'Catalyst::Authentication::Store::DBIx::Class' => '0.1506',
	'Catalyst::Plugin::Session::Store::FastMmap' => '0.16',
	'Catalyst::Plugin::Session::State::Cookie' => '0.17',
	'MooseX::MarkAsMethods' => '0.15'

#	'Test::MockObject'                 => '1.20150527'
    },

    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Yxes-Catalyst-Authentication-Credential-Google-*' },
);
