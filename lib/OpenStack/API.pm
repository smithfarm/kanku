package OpenStack::API;

use Moose;
use JSON::XS;
use HTTP::Request;
use LWP::UserAgent;
use Carp;

use OpenStack::API::Cinder;
use OpenStack::API::EC2;
use OpenStack::API::Glance;
use OpenStack::API::Nova;
use OpenStack::API::Quantum;
use OpenStack::API::Neutron;


has os_auth_url => (
  is	  => 'rw',
  isa	  => 'Str',
  default => $ENV{OS_AUTH_URL} || q{},
);

has os_tenant_name => (
  is	  => 'rw',
  isa	  => 'Str',
  default => $ENV{OS_TENANT_NAME} || q{},
);

has os_username => (
  is	  => 'rw',
  isa	  => 'Str',
  default => $ENV{OS_USERNAME} || q{},
);

has os_password => (
  is	  => 'rw',
  isa	  => 'Str',
  default => $ENV{OS_PASSWORD} ||q{},
);

has __access => (
  is	  => 'rw',
  isa	  => 'HashRef',
);

has __api_versions => (
  is	  => 'ro',
  isa	  => 'HashRef',
  default => sub  {
    {
      '2.0' => {
	tokens_url => 'tokens'
      },
      '3' => {
	tokens_url => 'auth/tokens'
      }
    }
  },
);

has os_auth_api_version => (
  is	  => 'rw',
  isa	  => 'Str',
  lazy	  => 1,
  default => sub {
    $_[0]->os_auth_url =~ m#/v([0-9\.]+)/$#;
    return $1 || '2.0';
  },
);

sub tokens_url {
  my ($self) = @_;
  return $self->__api_versions->{$self->os_auth_api_version}->{tokens_url};
}

sub authenticate {
  my ($self) = @_;


  croak("No os_auth_url given\n") unless $self->os_auth_url;

  my $uri	= $self->os_auth_url.$self->tokens_url;
  my $ua	= LWP::UserAgent->new();
  my $content	= $self->_auth_json_string;
  my $response  = $ua->post($uri,'Content-Type' => 'application/json', 'Content' => $content);

  if (! $response->is_success) {
    croak("Error while accessing uri '$uri'\n"
      . $response->status_line . "\n");
  }

  my $json = decode_json($response->decoded_content);

  $self->__access($json->{access});

  return $self->__access->{'token'}->{'id'}
}

sub _auth_json_string {
  my ($self) = @_;

  my $struct = {
    auth => {
      tenantName	  => $self->os_tenant_name,
      passwordCredentials => {
	username  => $self->os_username,
	password  => $self->os_password,
      }
    }
  };

  return encode_json($struct);

}
sub service {
  my ($self,$key,$value) = @_;

  $self->authenticate if (! $self->__access );

  my @service = grep { $_->{$key} eq $value } @{$self->__access->{serviceCatalog}};

  croak("Cannot find service with $key is $value!") if (! @service);
  croak("Ambiguous result for service with $key is $value!") if (@service > 1);

  my $mod = 'OpenStack::API::'. ucfirst($service[0]->{name});

  return $mod->new(%{$service[0]},access => $self);
}

1;

__END__

=head1 NAME

OpenStack::API

=head1 SYNOPSIS

  my $osa = OpenStack::API->new();

  my $osa->authenticate();

  my $nova = $osa->service(type => 'compute');

=head1 ATTRIBUTES

=head2 os_auth_url

default: $ENV{OS_AUTH_URL}

=head2 os_tenant_name

default: $ENV{OS_TENANT_NAME}

=cut

=head2 os_auth_api_version

=cut

=head2 os_username

default: $ENV{OS_USERNAME}

=cut

=head2 os_password

default: $ENV{OS_PASSWORD}

=cut

=head1 METHODS

=head2 tokens_url

=cut

=head2 authenticate

=cut

=head2 service

  my $nova    = $osa->service(type => 'compute');

  my $glance  = $osa->service(name => 'glance');

=cut

