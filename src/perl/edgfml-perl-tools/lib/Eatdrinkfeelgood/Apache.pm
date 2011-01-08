{

=pod

=head1 NAME

Eatdrinkfeelgood::Apache

=head1 SUMMARY 

 <Directory "/path/to/recipes">
  SetHandler  perl-script
  PerlHandler Eatdrinkfeelgood::Apache

  PerlSetVar  Cache             On
  PerlSetVar  CacheRoot         /path/to/root

  PerlAddVar  IndexIncludeEnd   xml
  PerlSetVar  IndexIncludeDirs  On

  PerlSetVar  RecipeStylesheet         /path/to/eatdrinkfeelgood.xsl
  PerlSetVar  DirectoryStylesheet      /path/to/eatdrinkfeelgood-index.xsl
 </Directory>

=head1 DESCRIPTION

A mod_perl handler for displaying, and generating directory indices of Eatdrinkfeelgood documents using XSLT.

=head1 NOTES

=head2 XSL files

The default eatdrinkfeelgood stylesheets are not included with this distribution. They can be downloaded separately from the eatdrinkfeelgood homepage. See below for link.

=head2 PDF files

There is some high degree of weirdness involving mod_perl, FreeBSD 4.x and Perl 5.6.1 that prevent the automagic PDF generation from working properly on my machine. Specifically, XML::Parser causes the http daemon to core dump.

I am currently redirecting to a simple cgi-script (see /cgi) in &handler. I've left the code in place in case you have the same problem. This is a decidely unsatisfactory solution, but...it works. If you don't then, please use the Eatdrinkfeelgood::PDF::IndexCard methods.

=cut

package Eatdrinkfeelgood::Apache;
use strict;

use vars qw ( $VERSION );
$VERSION = 0.3.1;

use Apache;
use Apache::Constants qw (:common REDIRECT);
use Apache::File;
use Apache::Log;
use Apache::URI;
    
use XML::LibXML;
use XML::LibXSLT;

use Cache::FileCache;
use Digest::MD5;
use File::Basename;

use Eatdrinkfeelgood::Directory::Index;
use Eatdrinkfeelgood::PDF::IndexCard;

my $global_xml = undef;
my $global_xsl = undef;

sub handler {
    my $apache = shift;

    my $uri   = Apache::URI->parse($apache);
    my $fname = $apache->filename();

    if ($uri->query() =~ /^(pdf)$/) {

	# If you don't understand what's going on
	# here, please read the POD:NOTES.

	my $q =  $uri->path();
	$q    =~ s/\/food\/recipes\///;
	my $r = join("/",join("://",$uri->scheme(),$uri->hostinfo()),"cgi-bin/pdf-gen?recipe=$q");    

	$apache->headers_out()->set("Location"=>$r);
	return REDIRECT;

	#$apache->content_type("application/pdf");
	#$apache->send_http_header();
	# my $card = Eatdrinkfeelgood::PDF::IndexCard->new()
	#      || return undef;
	# print $card->print($fname)
	# return OK;
    }

    # I am a directory. Do I have a trailing slash?
    # Redirect, if not.
    
    if (-d $fname) {
	unless ($apache->path_info() =~ m!/$!) {

	    my $redirect = $apache->uri()."/";

	    if (my $query = $uri->query()) {
		$redirect = join("?",$redirect,$query);
	    }

	    $apache->header_out("Location" => $redirect);
	    return REDIRECT;
	}
    }
    
    my $output = (-d $fname) ? 
	&transform($apache,file=>$fname,string=>&render_directory($apache,$fname)) : 
	    &transform($apache,file=>$fname);
    
    $apache->content_type("text/html");
    $apache->send_http_header();
    
    print $$output;
    return OK;
}

sub transform {
    my $apache = shift;
    my %args = @_;

    my $file  = join(".",$args{'file'},"html");

    if (my $sr_cache = &read_cache($apache,$file,lastmod=>(stat($args{'file'}))[9])) {
	return $sr_cache;
    }

    $global_xml ||= XML::LibXML->new();
    $global_xsl ||= XML::LibXSLT->new();
    
    $global_xml->validation(1);

    my $source = ($args{'string'}) ? 
	$global_xml->parse_string($args{'string'}) : 
	    $global_xml->parse_file($args{'file'});
    
    my $style_doc = ($args{'string'}) ? 
	$global_xml->parse_file($apache->dir_config("DirectoryStylesheet")) :
	    $global_xml->parse_file($apache->dir_config("RecipeStylesheet"));

    # XSLT parameters
    my ($trail,$dirname) = &breadcrumbs($apache);

    my $uri = $apache->uri();
    $uri    =~ s/\/$//;
    
    my $stylesheet = $global_xsl->parse_stylesheet($style_doc);

    my $results    = $stylesheet->transform(
					    $source,
					    &XML::LibXSLT::xpath_to_string(crumbs  => $trail),
					    &XML::LibXSLT::xpath_to_string(dirname => $dirname),
					    &XML::LibXSLT::xpath_to_string(uri     => $uri),
					    );
    
    &write_cache($apache,$file,$stylesheet->output_string($results));

    return \$stylesheet->output_string($results);
}

sub render_directory {
    my $apache = shift;
    my $dir    = shift;
    
    my $index = Eatdrinkfeelgood::Directory::Index->new(directory=>$dir);

    if (my $sr_cache = &read_cache($apache,$dir,lastmod=>$index->last_modified())) {
	return $$sr_cache;
    }

    my $include_directories = undef;
    my $exclude_directories = undef;
    
    $include_directories = ($apache->dir_config("IndexIncludeDirs") =~ /^(on)$/i) ? 1 : 0;
    
    $index->include(
		 starting    => [ $apache->dir_config->get("IndexIncludeStart") ],
		 ending      => [ $apache->dir_config->get("IndexIncludeEnd") ],
		 directories => $include_directories,
		 );
    
    $index->exclude(
		 exclude     => [ $apache->dir_config->get("IndexExclude")      ],
		 starting    => [ $apache->dir_config->get("IndexExcludeStart") ],
		 ending      => [ $apache->dir_config->get("IndexExcludeEnd")   ],
		 directories => $exclude_directories,
		 );
    
     
    $index->valid_suffix($apache->dir_config->get("IndexValidSuffix"));
     
    my $output = $index->to_string();
    
    &write_cache($apache,$dir,$output);
    return $output;
}

=pod

=head1 CACHE FUNCTIONS

=cut

=pod

=head2 &read_cache($apache,$fname)

=cut

sub read_cache {
    my $apache = shift;
    my $fname  = shift;
    
    my ($cache, $cache_id) = &get_cache($apache,$fname);
	
    $cache || return undef;
    
    my $cache_obj = $cache->get_object($cache_id)
	|| return undef;

    &use_cache($apache,$cache_obj,@_) 
	|| return undef;

    return \$cache_obj->get_data();
}

=pod

=head2 &write_cache($apache,$fname,$data)

=cut

sub write_cache {
    my $apache  = shift;
    my $fname   = shift;

    my ($cache, $cache_id) = &get_cache($apache,$fname);
    $cache || return undef;

    $cache->set($cache_id,@_);
    return 1;
}

=pod

=head2 &use_cache($apache,$cache,%args)

=cut

sub use_cache {
    my $apache = shift;
    my $cache  = shift;
    my $args   = { @_ };

    my $last_mtime  = $args->{'lastmod'};
    my $cache_mtime = $cache->get_created_at();
    my $use_cache   = 1;

    # Has the file been modified since the last cache ?
    
    if (($use_cache) && ($last_mtime > $cache_mtime)) {
	$use_cache = 0;
    }
    
    # Has this package been modified since the last cache ?
    
    if ( ($use_cache) && ( (stat(__FILE__))[9] > $cache_mtime) ) {
	$use_cache = 0;
    }
    
    # Have the stylesheets changed ?
    my $xsl = (-d $apache->filename()) ? "DirectoryStylesheet" : "RecipeStylesheet";

    if ( ($use_cache) && ( (stat($apache->dir_config($xsl)))[9] > $cache_mtime) ) {
	$use_cache = 0;
    }
    
    return $use_cache;
}


=pod

=head2 &get_cache($apache,$fname)

=cut

sub get_cache {
    my $apache = shift;
    my $fname  = shift;

    return undef unless ($apache->dir_config("Cache") =~ /^(on)$/i);
    my $cdir   = $apache->dir_config("CacheRoot") || return undef;;

    my $cache  = Cache::FileCache->new({
	cache_root      => $cdir,
	
	# WTF is going on here ?!
	#
	# I need to look at how Cache::FileCache
	# is handling umasks. I really just 
	# want to set a umask of 027, but the
	# package ends up setting the permissions
	# as 0744. <sigh />
	#
	# This yields 0760.
	
	directory_umask => "015",
	
	# Note that files are actually written with
	# the user's (http) umask.
	
    });

    
    my $digest = Digest::MD5->new();

    $digest->add($fname);
    my $id = $digest->hexdigest();

    return ($cache,$id);
}

=pod

=head1 NAVIGATION FUNCTIONS

=cut

=pod

=head2 &breadcrumbs($apache)

=cut

sub breadcrumbs { 
    my $apache = shift;

    my $dirname = undef;
    my @trail   = ();
    my $path    = undef;

    my $root = $apache->location();
    my $doc  = $apache->document_root();
    (my $crumb_root = $root) =~ s/^$doc//;

    if (-d $apache->filename()) {
	$path = $apache->filename();
    } else {
	$path    = &dirname($apache->filename());
	$dirname = &basename($apache->filename());
    }

    $path =~ /($root)(.*)(\/)*$/;

    my @crumbs  = split(/\//,$2);
    $crumbs[0]  = "index";

    $dirname ||= $crumbs[$#crumbs];

    if ($crumbs[1]) {

	my $first = $crumb_root || "/";
	push(@trail ,"<a href= \"$first\">$crumbs[0]</a>" );
	
	for (my $i = 1;$crumbs[$i];$i++) {
	    if ($crumbs[$i] eq $dirname) {
		push(@trail,$crumbs[$i]);
		next;
	    }
	    
	    my $href = join("/",$crumb_root,@crumbs[1..$i]);
	    my $str  = "<a href = \"$href\">$crumbs[$i]</a>";
	    
	    push(@trail,$str);
	}
    }

    return (join(" . ",@trail),$dirname);
}

=pod

=head1 TO DO

=over 4

=item

As always, finish the POD

=item

Figure out why PDF files render as blank in IE (Win). Plug-in problem?

=item

Figure out how Cache::FileCache is setting umask (see notes in I<get_cache>)

=back

=head1 VERSION

0.3.1

=head1 CHANGES 

=head2 0.3.1

=over 4

=item

Dereferenced cache data before returning in I<&render_directory>

=back

=head2 0.3

=over 4

=item

First public release

=back

=head1 DATE

$Date: 2002/12/20 04:44:27 $

=head1 AUTHOR

Aaron Straup Cope 

=head1 SEE ALSO

http://www.aaronland.net/food/edfgml

=head1 LICENSE

Copyright 2001, Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
