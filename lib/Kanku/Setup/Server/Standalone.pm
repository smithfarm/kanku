package Kanku::Setup::Server::Standalone;

use Moose;

use Path::Class qw/file/;

with 'Kanku::Setup::Roles::Common';
with 'Kanku::Setup::Roles::Server';
with 'Kanku::Roles::Logger';

sub setup {
  my $self    = shift;
  my $logger  = $self->logger;
  
  $logger->debug("Running server setup");
  
  
  $self->_dbfile(
    file(
      $self->app_root,
      "var",
      "db",
      "kanku-schema.db"
    )->stringify
  );
  
  $self->user("kankurun");
  
  $self->_setup_database();
  
  $self->_configure_apache if $self->_apache;
  
  $self->_configure_libvirtd_access();
  
  $self->_create_config_from_template(
    "etc/config.yml.tt2",
    "/opt/kanku/etc/config.yml",
    {  
       db_file => $self->_dbfile,
       use_publickey => 1
    }
  );
  
  $self->_create_default_pool;
  
  $self->_create_default_network;
  
  $self->_set_sudoers();
  
  $self->_create_ssh_keys;
  
  $logger->info("Server mode setup successfully finished!");
  $logger->info("To make sure libvirtd is coming up properly we recommend a reboot");

}

1;
