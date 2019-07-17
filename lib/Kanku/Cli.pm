# Copyright (c) 2016 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
package Kanku::Cli;

use MooseX::App qw(Color BashCompletion);

use Log::Log4perl;
use Kanku::Config;

app_exclude 'Kanku::Cli::Roles';

my $lconf = (-e "$ENV{HOME}/.kanku/logging.conf" )
               ? "$ENV{HOME}/.kanku/logging.conf"
               : "/etc/kanku/logging/console.conf";

Log::Log4perl->init($lconf);

__PACKAGE__->meta->make_immutable();

1;