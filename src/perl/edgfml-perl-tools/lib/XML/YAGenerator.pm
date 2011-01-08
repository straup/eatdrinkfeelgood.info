{

=pod 

=head1 NAME

XML::YAGenerator

=head1 SUMMARY

use XML::YAGenerator;

my $writer = XML::YAGenerator->new(
                                   conformance=>"strict",
                                   encoding=>"UTF-8",
                                   pretty=>2,
                                  );

print 
   $writer->header(),
   $writer->foo({xmlns=>"http://w3.org/2001/foo"},
                $writer->bar("hello world."),
               );

# Prints

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<foo xmlns="http://w3.org/2001/foo">
  <bar>hello world</bar>
</foo>

=head1 DESCRIPTION

This module subclasses XML::Generator to fix some bugs in the creation of attributes and 
processing instructions.

=cut

# $Id: YAGenerator.pm,v 1.1.1.1 2002/12/20 04:44:28 asc Exp $
#
# $Log: YAGenerator.pm,v $
# Revision 1.1.1.1  2002/12/20 04:44:28  asc
# importing
#
# Revision 1.3  2001/10/21 14:28:44  asc
# YAGenerator.pm
#
# Revision 1.4  2001/08/20 19:06:12  asc
# Added explicit check for scalar-ref-ness in &encode_entities
#
# Revision 1.3  2001/08/20 18:55:05  asc
# Added match to escape '<' tags in &encode_entitites()
#
# Revision 1.2  2001/08/08 17:23:27  asc
# Added &encode_entities.
# Updated POD.
#
# Revision 1.1  2001/08/07 20:15:04  asc
# Initial revision
#

package XML::YAGenerator;
use strict;

use Carp;
use XML::Generator;

use vars qw ( @ISA );
@ISA   = qw ( XML::Generator );

my %entity = (
	      nbsp   => "&#160;",
	      iexcl  => "&#161;",
	      cent   => "&#162;",
	      pound  => "&#163;",
	      curren => "&#164;",
	      yen    => "&#165;",
	      brvbar => "&#166;",
	      sect   => "&#167;",
	      uml    => "&#168;",
	      copy   => "&#169;",
	      ordf   => "&#170;",
	      laquo  => "&#171;",
	      not    => "&#172;",
	      shy    => "&#173;",
	      reg    => "&#174;",
	      macr   => "&#175;",
	      deg    => "&#176;",
	      plusmn => "&#177;",
	      sup2   => "&#178;",
	      sup3   => "&#179;",
	      acute  => "&#180;",
	      micro  => "&#181;",
	      para   => "&#182;",
	      middot => "&#183;",
	      cedil  => "&#184;",
	      sup1   => "&#185;",
	      ordm   => "&#186;",
	      raquo  => "&#187;",
	      frac14 => "&#188;",
	      frac12 => "&#189;",
	      frac34 => "&#190;",
	      iquest => "&#191;",
	      Agrave => "&#192;",
	      Aacute => "&#193;",
	      Acirc  => "&#194;",
	      Atilde => "&#195;",
	      Auml   => "&#196;",
	      Aring  => "&#197;",
	      AElig  => "&#198;",
	      Ccedil => "&#199;",
	      Egrave => "&#200;",
	      Eacute => "&#201;",
	      Ecirc  => "&#202;",
	      Euml   => "&#203;",
	      Igrave => "&#204;",
	      Iacute => "&#205;",
	      Icirc  => "&#206;",
	      Iuml   => "&#207;",
	      ETH    => "&#208;",
	      Ntilde => "&#209;",
	      Ograve => "&#210;",
	      Oacute => "&#211;",
	      Ocirc  => "&#212;",
	      Otilde => "&#213;",
	      Ouml   => "&#214;",
	      times  => "&#215;",
	      Oslash => "&#216;",
	      Ugrave => "&#217;",
	      Uacute => "&#218;",
	      Ucirc  => "&#219;",
	      Uuml   => "&#220;",
	      Yacute => "&#221;",
	      THORN  => "&#222;",
	      szlig  => "&#223;",
	      agrave => "&#224;",
	      aacute => "&#225;",
	      acirc  => "&#226;",
	      atilde => "&#227;",
	      auml   => "&#228;",
	      aring  => "&#229;",
	      aelig  => "&#230;",
	      ccedil => "&#231;",
	      egrave => "&#232;",
	      eacute => "&#233;",
	      ecirc  => "&#234;",
	      euml   => "&#235;",
	      igrave => "&#236;",
	      iacute => "&#237;",
	      icirc  => "&#238;",
	      iuml   => "&#239;",
	      eth    => "&#240;",
	      ntilde => "&#241;",
	      ograve => "&#242;",
	      oacute => "&#243;",
	      ocirc  => "&#244;",
	      otilde => "&#245;",
	      ouml   => "&#246;",
	      divide => "&#247;",
	      oslash => "&#248;",
	      ugrave => "&#249;",
	      uacute => "&#250;",
	      ucirc  => "&#251;",
	      uuml   => "&#252;",
	      yacute => "&#253;",
	      thorn  => "&#254;",
	      yuml   => "&#255;",
	      );

my $entities = join('|', keys %entity);

=pod

=head1 NEW METHODS

These are methods that do not exist in the base class.

=head2 $pkg->header(%args)

TBW

=cut

sub header {
    my $self = shift;
    my $args = { @_ };

    my $head = $self->xmldecl();

    if (my $xsl = $args->{'stylesheet'}) {
	$head .= $self->xsldecl($xsl);
    }

    return $head;
}

=pod

=head2 $pkg->xsldecl($path)

Returns a valid XML processing intruction string.

=cut

sub xsldecl {
    my $this = shift;

  return $this->XML::Generator::util::tag('xsldecl', @_)
      unless $this->{conformance} eq 'strict';

    my $path = shift || croak "xsl declaration requires a path or filename";

    return "<?xml-stylesheet href = \"$path\" type = \"text/xsl\" ?>\n";
}

=pod

=head2 &encode_entities(\$string)

This is nothing more than the XML entity decoding algorithm found in Matt Sergeant's rssmirror.pl script. I find the encoding options provided by the base class confusing and unreliable.

=cut

sub encode_entities {
    my $text = shift;
    return unless (ref($text) eq "SCALAR");
    $$text =~ s/&(?!(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&amp;/g;
    $$text =~ s/&($entities);/$entity{$1}/g;
    $$text =~ s/</&lt;/g;
}

=pod

=head1 METHODS THAT HAVE BEEN OVERRIDDEN

These methods override those found in XML::Generator.pm

=head2 ch_syntax();

Allows for "xmlns" and "xml-stylesheet" attributes in tags.

This method is private to the package.

=cut

package XML::Generator::util;

sub ck_syntax {
    my($this, $name) = @_;
  # use \w and \d so that everything works under "use locale" and
  # "use utf8"
    if ($name =~ /^\w[\w\-\.]*$/) {
	if ($name =~ /^\d/) {
	    croak "name [$name] may not begin with a number";
	}
    } else {
	croak "name [$name] contains illegal character(s)";
    }
    if ($name =~ /^xml/i) {
	unless ($name =~ /^(xmlns|xml-stylesheet)$/) {
	    croak "names beginning with 'xml' are reserved by the W3C";
	}
    }
}

=pod

=head1 VERSION

1.0

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<XML::Generator>

http://xml.sergeant.org/download/rssmirror.pl

=head1 LICENSE


Copyright 2001, Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
