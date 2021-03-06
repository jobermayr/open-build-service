#
# Copyright (c) 2008 Adrian Schroeter, Novell Inc.
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
################################################################
#
# XML templates for the BuildService. See XML/Structured.
#

package BSProductXML;

use strict;
use Data::Dumper;
use File::Basename;
use XML::Structured ':bytes';

# 
# an explained example entry of this file
#
#our $pack = [             creates <package name="" project=""> space
#    'package' =>          
#	'name',
#	'project',
#	[],                before the [] all strings become attributes to <package>
#       'title',           from here on all strings become children like <title> </title>
#       'description',
#       [[ 'person' =>     creates <person> children, the [[ ]] syntax allows any number of them including zero
#           'role',        again role and userid attributes, both are required
#           'userid',    
#       ]],                this block describes a <person role="defeatist" userid="statler" /> construct
# 	@flags,            copies in the block of possible flag definitions
#       [ $repo ],         refers to the repository construct and allows again any number of them (0-X)
#];                        closes the <package> child with </package>

our $group = [
    'group' =>
          'name',
          'version',
          'release',
          [],
          [[ 'conditional' => 'name' ]],
          [[ 'include' => 'group' ]],
          [ 'pattern' =>
            'ordernumber',
            [],
            [ 'name' => '_content' ],
            [ 'icon' => '_content' ],
            [ 'visible' => '_content' ],
            [ 'category' => 'language', [], '_content' ],
            [ 'summary' => 'language', [], '_content' ],
            [ 'description' => 'language', [], '_content' ],
            [ 'relationships' =>
               [],
               [[ 'pattern' => 'name', 'relationship' ]],
            ],
          ],
          [[ 'packagelist' =>
             'relationship',
             'supportstatus',
             'id',
             [],
             [[ 'package' =>
                'name',
                'supportstatus',
                [[ 'conditional' => 'name' ]],
             ]],
          ]],
];

# Defines a single product, will be used in installed system to indentify it 
our $product = [
           'product' =>
           'id',
           'schemeversion',
           [],
           'vendor',
           'name',
           'version',       # shall not be used, if baseversion is used. It is baseversion.patchlevel than.
           'baseversion',
           'patchlevel',
           'migrationtarget',
           'release',
           'endoflife',     # in ISO 8601 format (YYYY-MM-DD)
           'arch',
           'cpeid',         # generated, not for input
           'productline',
           [ 'register' => 
              [],
              'target',     # distro-target for NCC, only for .prod files since SLE 12
              'release',
              'flavor',

              # following is for support tools
              [ 'pool' =>
                [[ 'repository' =>
                   'project',   # input
                   'name',
                   'media',
                   'arch',      # for arch specific definitions
                ]],
              ],
              [ 'updates' =>
                [[ 'distrotarget' =>     # for SMT update service
                   'arch',      # for arch specific definitions
                   [],
                   '_content'
                ]],
                [[ 'repository' =>
                   'project',   # input
                   'name',
                   [ 'zypp' => 'name', 'alias' ],
                   'repoid',    # output for .prod file
                   'arch',      # for arch specific definitions
                ]],
              ],
              [ 'repositories' =>
                [[ 'repository' =>
                   'path',
                ]],
              ], # this is for prod file export only, not used for SLE 12/openSUSE 13.2 media style anymore
           ],
           [ 'upgrades' =>     # to announce service pack releases
              [[ 'upgrade' =>
                 [],
                 'name',
                 'summary',
                 'repository',
                 'product',
                 'notify',
                 'status',
              ]],
           ],
           'updaterepokey',  # obsolete
           [[ 'summary' =>
              'language',
              [],
              '_content'
           ]],
           [[ 'shortsummary' =>
              'language',
              [],
              '_content'
           ]],
           [[ 'description' =>
              'language',
              [],
              '_content'
           ]],
           [ 'linguas' =>
             [],
             [[ 'language' => '_content' ]],
           ],
           [ 'urls' =>
             [],
             [[ 'url' => 
                'name',
                [],
                '_content',
             ]],
           ],
           [ 'buildconfig' =>
              [],
             'producttheme',
             'betaversion',
             'mainproduct',
             [ 'linguas' =>
               [],
               [[ 'language' => '_content' ]],
             ],
             'allowresolving',
             'packagemanager',
           ],
           [ 'installconfig' =>
              [],
              'defaultlang',
              'datadir',
              'descriptiondir',
              [ 'releasepackage' => 'name', 'flag', 'version', 'release' ],
              'distribution',
              [[ 'obsoletepackage' => '_content' ]],
           ],
           [ 'runtimeconfig' =>
              [],
              'allowresolving',
           ],
           [[ 'productdependency' =>
              'relationship',
              'name',
              'baseversion',
              'patchlevel',
              'release',
              'flavor',
              'flag',
           ]],
];

# Complete product definition. Defines how a media is setup
# and which products are available.
our $productdesc = [
    'productdefinition' =>
      'xmlns:xi',
      'schemeversion',
      [],
      [ 'products' =>
        [ $product ],
      ],
      [ 'conditionals' =>
        [[ 'conditional' =>
           'name',
           [[ 'platform' =>
              'excludearch',
              'onlyarch',
              'arch',
              'baselibs_arch',
              'addarch',
              'replace_native'
           ]],
           [ 'media' => 
             'number',
           ],
        ]],
      ],
      [ 'repositories' =>
        [[ 'repository' =>
           'path',
           'build',
           'product_file',
        ]],
      ],
      [ 'archsets' =>
        [[ 'archset' => 
             'name',
             'productarch',
             [],
             [[ 'arch' => '_content' ]],
        ]],
      ],
      [ 'mediasets' =>
         [[ 'media' =>
            'type',
            'product',                 # obsolete, should not be used anymore
            'name',
            'flavor',
            'repo_only',                    # do not create iso files
            'drop_repo',                    # remove trees, just having iso files as result
            'mediastyle',
            'firmware',
            'registration',
            'create_repomd',
            'sourcemedia',
            'debugmedia',
            'create_pattern',
            'ignore_missing_packages',      # may be "true", default for mediastyle 11.3 and before
            'ignore_missing_meta_packages', # may be "true", default for mediastyle 11.3 and before
            'skip_release_package',         # skip adding the release packages to the media
            'run_media_check',
            'run_hybridiso',
            'run_make_listings',
            'use_recommended',
            'use_suggested',
            'use_required',
            'use_undecided', # take all packages, even the ungrouped ones
            'allow_overflow',
            'next_media_in_set',
            'size',
            'datadir',
            'descriptiondir',
            [[ 'preselected_patterns' => 
               [[ 'pattern' =>
                  'name',
	       ]]
            ]],
            [[ 'archsets' =>
              [[ 'archset' => 
                   'ref',
              ]],
            ]],
            [[ 'use' =>
               'group',
               'use_recommended',
               'use_suggested',
               'use_required',
               'create_pattern',
               [[ 'package' => 'name', 'medium', 'relationship', 'arch', 'addarch' ]],
               [[ 'include' => 'group', 'relationship' ]],
            ]],
            # product dependency got moved to product definition
            [[ 'productdependency' =>
               'relationship',
               'name',
               'version',
               'patchlevel',
               'release',
               'flavor',
               'flag',
            ]],
            [ 'metadata' =>
               [[ 'package' => 'name', 'medium', 'arch', 'addarch', 'onlyarch', 'removearch' ]],
               [[ 'file' => 'name' ]],
            ],
         ]],
      ],
      [ $group ],
];

# list of product definitions
our $products = [
   'productlist' =>
      [ $productdesc ],
];

our $productrepositories = [
  'product' =>
    'name',
    [[
      'distrotarget' => 
        'arch', # optional
        [],
        '_content',
    ]],
    [[
      'repository' =>
        'path',
        'arch', # optional
        [],
        [ 'zypp' => 'name', 'alias' ],
        'debug',  # optional flags
        'update',
    ]],
];
our $productlistrepositories = [
   'productrepositories' =>
      [ $productrepositories ],
];

sub mergexmlfiles {
  my ($absfile, $seen, $debug, $files) = @_;

  if ($seen->{$absfile}) {
    print "ERROR: cyclic file include ($absfile)!\n";
    return undef;
  }
  my $data;
  my ($dummy, $dir) = fileparse( $absfile );

  local *F;
  if (!open(F, '<', $absfile)) {
    return undef;
  }
  my $str = '';
  1 while sysread(F, $str, 8192, length($str));
  close F;

  # wipe out comments globally
#  $str =~ s/<!--.+?-->//gs;

  if( $debug && open F, ">/tmp/naked.xml" ) {
    print F $str;
    close F;
  }

  while ($str =~ /<xi:include href="(.+?)".*?>/s) {
     my $ref = $1;
     if ($ref =~ /^obs:.+/) {
       print "ERROR: obs: references are not handled yet ! \n";
       return undef;
     } else {
       if ($ref =~ /^\."/ || $ref =~ /\//) {
         print "ERROR: obs: reference to illegal file ! \n";
         return undef;
       }
       my $file = "$dir$ref";
       if (defined($files)) {
         # running via the source server, find the file in source archive
         $file = "$dir/$files->{$ref}-$ref"
       };
       $seen->{$absfile} = 1;
       my $replace = mergexmlfiles( $file, $seen, $debug );
       delete $seen->{$absfile};
       if ( ! defined $replace ) {
         print "ERROR: Unable to read $file !\n";
         return undef unless $replace;
       }
       # This is a subfile, so wipe out the xml header.
       $replace =~ s/<\?xml .+\?>//;
       $str =~ s/<xi:include href=".+?".*?>/$replace/s;
     }
  }

  if( $debug && open F, ">/tmp/naked_all.xml" ) {
    print F $str;
    close F;
  }

  return $str;
}

sub readproductxml {
  my ($file, $nonfatal, $debug, $files) = @_;

  my $str = mergexmlfiles( $file, {}, $debug, $files );
  return undef if ( ! $str );

  return XMLin($productdesc, $str) unless $nonfatal;
  eval { $str = XMLin($productdesc, $str); };
  return $@ ? undef : $str;
}

sub getproductrepositories {
  my ($xml) = @_;

  my $p;
  for my $product (@{$xml->{'products'}->{'product'}}) {
    my @pr;
    for my $repo (@{$product->{'register'}->{'updates'}->{'repository'}}) {
      my $project_expanded = $repo->{'project'};
      $project_expanded =~ s/:/:\//g;
      my $path = { 'path' => "/$project_expanded/$repo->{'name'}", 'update' => undef };
      $path->{'arch'} = $repo->{'arch'} if $repo->{'arch'};
      $path->{'zypp'} = $repo->{'zypp'} if $repo->{'zypp'};
      $path->{'debug'} = undef if $repo->{'name'} =~ m/_debug$/;
      push @pr, $path;
    };
    for my $repo (@{$product->{'register'}->{'pool'}->{'repository'}}) {
      my $project_expanded = $repo->{'project'};
      $project_expanded =~ s/:/:\//g;
      my $path = { 'path' => "/$project_expanded/$repo->{'name'}/repo/$repo->{'media'}" };
      $path->{'arch'} = $repo->{'arch'} if $repo->{'arch'};
      push @pr, $path;
    };
    my $prod = { "name" => $product->{'name'}, "repository" => \@pr };
    $prod->{"distrotarget"} = $product->{'register'}->{'updates'}->{'distrotarget'} if $product->{'register'}->{'updates'}->{'distrotarget'};
    push @{$p}, $prod;
  };

  return $p;
}

1;
