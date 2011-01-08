=pod

=head1 NAME

Eatrdinkfeelgood::Directory::Index

=head1 SUMMARY

 use Eatdrinkfeelgood::Directory::Index

 my $index = Eatdrinkfeelgood::Directory::Index->new();

 $index->directory("/path/to/directory");

 $index->exclude("foobar");

 $index->exclude(exclude=>["cows","dogs"],ending=>[".core"]);

 $index->valid_suffix("dbk","foo");

 print $index->to_string();

=head1 DESCRIPTION

TBW

=head1 NOTES

I would have liked to use Petr Cimprich's XML::Directory::SAX and I may yet. I am sticking with this module for the time being because it has better support for including/excluding files and because there didn't seem to be any (simple) way to get XML::Directory::SAX to stream files alphabetically.

In turn, this module uses another tailor-made module, XML::YAGenerator. This is a subclass to add fixes and functionality to XML::Generator.

=cut

package Eatdrinkfeelgood::Directory::Index;
use strict;

use vars qw ( $VERSION );
$VERSION = 0.3;

use DirHandle;

use XML::Parser::PerlSAX;
use XML::YAGenerator;

my $xml;

my @exclude             = qw ( );

# This array uses quotes to stop this error:
# Possible attempt to put comments in qw() list
my @exclude_starting    = ( "\\.", "RCS", "CVS", "#" );

my @exclude_ending      = qw ( ~ );
my @default_suffix      = qw ( xml );

my @funcs_to_memoize    = qw ();
my @user_defined_limits = qw ( _exclude _exclude_starting _exclude_ending _include_starting _include_ending _valid_suffix );

=head1 PUBLIC METHODS

=head2 new(%args)

Valid arguments are

=cut

sub new {
    my $pkg = shift;
    
    my $self = {};
    bless $self, $pkg;

    $self->init(@_) || return undef;
    return $self;
}

sub init {
    my $self = shift;
    my $args = { @_ };

    if (my $d = $args->{'directory'}) {
	$self->directory($d) || return 0;
    }

    map { $self->{$_} = []; } @user_defined_limits;
    
    return 1;
}


=pod

=head2 $pkg->to_string()

=cut

sub to_string {
    my $self = shift;
    return $self->_index();
}

=pod

=head2 $pkg->to_file($path)

=cut

sub to_file {
    my $self = shift;
    my $path = shift;

    my $fh = FileHandle->new();
    $fh->open(">$path") 
	|| return undef;

    print $fh $self->_index();
    
    $fh->close();
    return 1;
}

=head2 $pkg->directory($directory)

Get/set the directory that the object will index.

=cut

sub directory {
    my $self      = shift;
    my $directory = shift;

    if ($directory) {

	if ($self->{'_directory'}) {
	    map { $self->{$_} = []; } @user_defined_limits;
	    $self->{'directory'} = undef;
	}    
	
	if (-d $directory) {
	    $self->{'_directory'} = $directory;
	}
	
    }
    
    return $self->{'_directory'};
}

=pod

=head2 $pkg->last_modified()

Returns an array contain the mtime and filename for the most recently modified file.

=cut

sub last_modified {
    my $self = shift;
    return $self->_determine_lastmod($self->directory());
}

=pod

=head2 $pkg->include(%args)

Include *only* that files that match either the starting or ending pattern. Default exclusions remain in effect and are processed first.

Valid arguments are :

=over 4

=item starting

=item ending

=item directories

=back

=cut

sub include {
    my $self = shift;
    my $args = { @_ };

    if (ref($args->{'starting'}) eq "ARRAY") {
	push (@{$self->{'_include_starting'}},@{$args->{'starting'}});
    }

    if (ref($args->{'ending'}) eq "ARRAY") {
	push (@{$self->{'_include_ending'}},@{$args->{'ending'}});
    }

    $self->{'_include_subdirs'} = $args->{'directories'};
    return 1;
}

=pod

=head2 $pkg->exclude(%args)

Exclude files with a particular name or pattern from being included in the directory listing.

Valid arguments are :

=over 4

=item exclude

=item starting

=item ending

=item directories

=back

=cut

sub exclude {
    my $self = shift;
    my $arg  = { @_ };

    push (@{$self->{'_exclude'}},@{$arg->{'exclude'}})           if (ref($arg->{'exclude'})  eq "ARRAY");
    push (@{$self->{'_exclude_starting'}},@{$arg->{'starting'}}) if (ref($arg->{'starting'}) eq "ARRAY");
    push (@{$self->{'_exclude_ending'}},@{$arg->{'ending'}})     if (ref($arg->{'ending'})   eq "ARRAY");
    
    $self->{'_exclude_subdirs'} = $arg->{'directories'};

    return 1;
}

=pod 

=head2 $pkg->valid_suffix(@args)

Add one or more suffixes to the list of files that will be assumed to be DocBook and targeted for parsing.

Default is "xml"

=cut

sub valid_suffix {
    my $self = shift;
    push( @{ $self->{'_valid_suffix'} } , @_ );
}

=pod

=head1 PRIVATE METHODS

=cut

=head2 $pkg->_index()

Returns the contents of the object's directory as an XML string.

=cut

sub _index {
    my $self = shift;

    my $dir   = $self->directory() || return undef;
    my @files = $self->_read_directory($dir);

    # Load tools for generating XML
    $xml = XML::YAGenerator->new(conformance=>"strict",encoding=>"UTF-8",pretty=>2);
    my $output = "";

    # Start generating the index
    foreach my $f (@files) {

	my $fpath = "$dir/$f";

	my $id = $f;
	&XML::YAGenerator::encode_entities(\$id);

	my %attributes = (
			  id      => $id,
			  lastmod => (stat($fpath))[9],
			  );

	# Directory. No XML here.

	if (-d $fpath) {
	    $output .= $xml->directory(
				       \%attributes,
				       );
	    next;
	}

	# Obviously not an XML file. No XML here.

	my @valid_suffixes = ( @default_suffix,@{$self->{'_valid_suffix'}} );
	
	$fpath =~ /(.*)\.(.*)$/;

	unless (grep /^($2)$/,@valid_suffixes) {
	    $output .= $xml->file(
				  \%attributes,
				  );
	    next;
	}

	$output .= &_parse($id,$fpath,\%attributes);
	
    }

    # Finish generating XML and return the results
    return $xml->xmldecl().$xml->index({id=>$dir},$output);
}

=pod

=head2 $pkg->_read_directory($path)

=cut

sub _read_directory {
    my $self      = shift;
    my $directory = shift;

    my $dh = DirHandle->new($directory) || return ();

    my $exclude          = join("|",@exclude);
    my $exclude_starting = join("|",@exclude_starting);
    my $exclude_ending   = join("|",@exclude_ending);
    
    my @files = grep { ! /^($exclude)$/ && ! /^($exclude_starting)/ && ! /($exclude_ending)$/ } $dh->read();

    my $include_starting = join("|",@{ $self->{'_include_starting'} });
    my $include_ending   = join("|",@{ $self->{'_include_ending'} });
    
    if ($include_starting || $include_ending) {
	@files = grep { /^$include_starting/ && /$include_ending$/ } @files;

	if ($self->{'_include_subdirs'}) {
	    return sort @files,&_list_subdirs($directory);
	}

	return sort @files;
    }

    $exclude          = join("|",@{$self->{'_exclude'}});
    $exclude_starting = join("|",@{$self->{'_exclude_starting'}});
    $exclude_ending   = join("|",@{$self->{'_exclude_ending'}});

    @files = grep { ! /^($exclude)$/         } @files if ($exclude);
    @files = grep { ! /^($exclude_starting)/ } @files if ($exclude_starting);
    @files = grep { ! /($exclude_ending)$/   } @files if ($exclude_ending);

    if ($self->{'_exclude_subdirs'}) {
	my @dirs = &_list_subdirs($directory);
	return sort &_remove_dirs(\@files,\@dirs);
    }

    return sort @files;
}

=pod

=head2 $pkg->_remove_dirs(\@dirs)

=cut

sub _remove_dirs {
    my $files = shift;
    my $dirs  = shift;

    my @okay = ();

    foreach my $f (@$files) {
	next if (grep /^($f)$/,@$dirs);
	push(@okay,$f);
    }
    
    return @okay;
}

=pod

=head2 $pkg->_determine_lastmod($path)

=cut

sub _determine_lastmod {
    my $self      = shift;
    my $directory = shift;

    my @files = $self->_read_directory($directory);

    my $mtime = 0;
    my $fname = "";

    foreach my $f (@files) {
	my $lastmod = (stat("$directory/$f"))[9] || 0;
	next if ($lastmod < $mtime);

	$mtime = $lastmod;
	$fname = $f;
    }

    (wantarray) ? return ($mtime, $fname) : return $mtime;
}

=pod

=head1 PRIVATE FUNCTIONS

=cut

=pod

=head2 &_parse($f,$fpath,$attributes)

=cut

sub _parse {
    my $f          = shift;
    my $fpath      = shift;
    my $attributes = shift;

    my $handler = SAX->new();
    my $parser  = XML::Parser::PerlSAX->new(Handler => $handler);

    my $parse_data = {};

    eval { $parse_data = $parser->parse(Source=>{SystemId=>$fpath}); };

    if (my $errstr = $@) {

	&XML::YAGenerator::encode_entities(\$f);
	&XML::YAGenerator::encode_entities(\$errstr);
	
	return $xml->file(
			  $attributes,
			  $xml->title($f),
			  $xml->error($errstr),
			  );
	
    }

    my $author   = "$parse_data->{'firstname'} $parse_data->{'othername'} $parse_data->{'surname'}";
    my $title    = $parse_data->{'title'}    || $f;
    my $abstract = $parse_data->{'abstract'} || "";
    
    &XML::YAGenerator::encode_entities(\$author);
    &XML::YAGenerator::encode_entities(\$title);
    &XML::YAGenerator::encode_entities(\$abstract);

    return $xml->file(
		      $attributes,
		      $xml->author($author),
		      $xml->title($title),
		      $xml->abstract($abstract),
		      );
}


=pod

=head2 &_list_subdirs($path)

=cut

sub _list_subdirs {
    my $directory = shift;

    my $dh = DirHandle->new($directory);

    my $exclude          = join("|",@exclude);
    my $exclude_starting = join("|",@exclude_starting);
    my $exclude_ending   = join("|",@exclude_ending);
    
    return grep { -d "$directory/$_" && ! /^($exclude)$/ && ! /^($exclude_starting)/ && ! /($exclude_ending)$/ } $dh->read();
}

package SAX;
use Data::Dumper;

my %parse_data = ();
my $chardata   = "";

my $history    = 0;
my $name       = 0;

my $title      = undef;
my $source     = undef;
my $abstract   = undef;

sub new {
    my $pkg = shift;
    return bless {}, $pkg;
}

sub start_document {
    %parse_data = ();
}

sub end_document {
    return \%parse_data;
}

sub start_element {
    my $self    = shift;
    my $element = shift;

    my $tag = $element->{'Name'} || "";

    if ($tag eq "name") {
	$name = 1;
    }

    if ($tag eq "source") {
	$source = $element->{'Attributes'}->{"content"};
    }

    if ($tag eq "history") {
	$history = 1;
    }
}

sub end_element {
    my $self    = shift;
    my $element = shift;

    my $tag = $element->{'Name'} || "";

    if (($name) && ($tag eq "common")) {
	$title = $chardata;
    }

    if ($tag eq "source") {
	$parse_data{ "title" } = "$title ($source)";
    }

    if ($tag eq "history") {
	$parse_data{ "abstract" } = $abstract;
	$abstract = undef;
	$history  = 0;
    }

    if (($tag eq "para") && ($history)) {
	$abstract .= $chardata;
    }

    $chardata = "";
}

sub characters {
    my $self       = shift;
    my $characters = shift;

    my $text = $characters->{Data};
    $text =~ s/^\s*//;
    $text =~ s/\s*$//;

    $chardata .= $text;
}

return 1;

=pod

=head1 TO DO

=over 4

=item

Finish POD

=item

Finesse lastmod methods

=item

Figure out what to do about memoization.

=item

Abstratify, abstractify, abstractify and then inherit. Then learn to play nicely with XML::Directory.

=back

=head1 VERSION

0.3

=head1 DATE

$Date: 2002/12/20 04:44:28 $

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<XML::Parser::PerlSAX>

L<XML::Directory>

http://www.aaronland.net/food/edfgml

=head1 LICENSE

Copyright 2001, Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut
