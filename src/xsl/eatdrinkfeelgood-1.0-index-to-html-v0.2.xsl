<!-- ====================================================================== -->
<!-- eatdrinkfeelgood-index.xsl                                             -->
<!--                                                                        -->
<!-- This stylesheet renders an XML document produced by the                -->
<!-- Eatdrinkfeelgood::Directory::Index Perl module as an HTML document.    -->
<!--                                                                        -->
<!-- Version : 0.2                                                          -->
<!-- Date    : $Date: 2002/12/20 04:44:27 $                                 -->
<!--                                                                        -->
<!-- Copyright (c) Aaron Straup Cope 2001                                   -->
<!-- http://www.aaronland.net/food/edfgml                                   -->
<!--                                                                        --> 
<!-- This is free software, you may use it and distribute it under the same -->
<!-- terms as the Perl Artistic License.                                    -->
<!-- http://language.perl.com/misc/Artistic.html                            -->
<!--                                                                        --> 
<!-- ====================================================================== -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

 <xsl:output method="html" />

<!-- ====================================================================== -->
<!-- parameters                                                             -->
<!--                                                                        -->
<!-- These are set by the Eatdrinkfeelgood::Apache mod_perl handler         -->
<!--                                                                        -->
<!-- ====================================================================== -->

 <xsl:param name = "crumbs" />
 <xsl:param name = "dirname" />
 <xsl:param name = "uri" />

<!-- ====================================================================== -->
<!-- match : /                                                              -->
<!-- ====================================================================== -->

 <xsl:template match="/">
  <html xmlns="http://www.w3.org/1999/xhtml" lang="en-CA">
   <head>
    <title><xsl:value-of select = "$dirname" /></title>
    <xsl:call-template name = "Styles" />
   </head>
   <body>
    <xsl:call-template name = "Main" />
   </body>
  </html>
 </xsl:template>

<!-- ====================================================================== -->
<!-- match : directory                                                      -->
<!-- ====================================================================== -->

 <xsl:template match = "directory">
  <div class = "listitem">
  <xsl:call-template name = "Title">
   <xsl:with-param name = "type">directory</xsl:with-param>
  </xsl:call-template>
  </div>
 </xsl:template>

<!-- ====================================================================== -->
<!-- match : file                                                           -->
<!-- ====================================================================== -->
        
 <xsl:template match = "file">
  <xsl:choose>
   <xsl:when test = "title">
    <xsl:call-template name = "Recipe" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name = "Unknown" />          
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

<!-- ====================================================================== -->
<!-- template : Main                                                        -->
<!-- ====================================================================== -->

 <xsl:template name = "Main">
  <div>
   <xsl:call-template name = "Breadcrumbs" /> 
   <xsl:call-template name = "OtherFormats" />        
  </div>
  <div class = "main" style = "">
   <xsl:apply-templates />
  </div>
 </xsl:template>

<!-- ====================================================================== -->
<!-- template : Breadcrumbs                                                 -->
<!-- ====================================================================== -->

 <xsl:template name = "Breadcrumbs">
  <div class = "breadcrumbs" style = "float:left;">
  <xsl:choose>
   <xsl:when test = "$crumbs = ''">
    eatdrinkfeelgood
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select = "$crumbs" disable-output-escaping = "yes" />      
   </xsl:otherwise>
  </xsl:choose>
  </div>
 </xsl:template>

<!-- ====================================================================== -->
<!-- template : OtherFormats                                                -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "OtherFormats">
 <xsl:if test = "$uri">   
 <div style = "background-color:beige;float:right;padding-top:10px;">
  <xsl:attribute name = "class">pdflink</xsl:attribute>
  <a>
    <xsl:attribute name = "href"><xsl:value-of select = "$uri" />?pdf</xsl:attribute>
   <img>
    <xsl:attribute name = "src">/icons/pdf.gif</xsl:attribute>
    <xsl:attribute name = "border">0</xsl:attribute>
   </img>
  </a>
  &#160;        
 </div>  
 </xsl:if>
</xsl:template>

<!-- ====================================================================== -->
<!-- template : Title                                                       -->
<!-- ====================================================================== -->

 <xsl:template name = "Title">
  <xsl:param name = "type" />
  <div>
   <xsl:attribute name = "class"><xsl:value-of select = "$type" /></xsl:attribute>
   <a>
    <xsl:attribute name = "href">./<xsl:value-of select = "@id" />?pdf</xsl:attribute>
    <img src = "/icons/pdf.gif" border = "0" align = "bottom" />
   </a>
   &#160;
   <a>
    <xsl:attribute name = "href">./<xsl:value-of select = "@id" /></xsl:attribute>
    <img>
     <xsl:attribute name = "src">
      <xsl:choose>
       <xsl:when test = "$type = 'directory'" >/icons/folder.gif</xsl:when>
       <xsl:otherwise>/icons/text.gif</xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>
     <xsl:attribute name = "border">0</xsl:attribute>
     <xsl:attribute name = "align">bottom</xsl:attribute>
    </img>
   </a>
   &#160;

   <xsl:variable name = "title" select = "./title" />

   <xsl:choose>
     <xsl:when test = "$title != ''">
      <xsl:variable name = "author" select = "./author" />

      <xsl:call-template name = "TitleLink">
       <xsl:with-param name = "title">
        <xsl:value-of select = "$title" />
       </xsl:with-param>
      </xsl:call-template>

      <xsl:if test = "$author != ''">
       &#160;
       <em><xsl:value-of select = "$author" /></em>                 
      </xsl:if>

     </xsl:when>
     <xsl:otherwise>
      <xsl:call-template name = "TitleLink">
       <xsl:with-param name = "title">
        <xsl:value-of select = "./@id" />
       </xsl:with-param>
      </xsl:call-template>

     </xsl:otherwise>
   </xsl:choose>

  </div>
 </xsl:template>

<!-- ====================================================================== -->
<!-- template : TitleLink                                                   -->
<!-- ====================================================================== -->

 <xsl:template name = "TitleLink">
  <xsl:param name = "title" />
  <a>
   <xsl:attribute name = "href">./<xsl:value-of select = "@id" /></xsl:attribute>
   <xsl:value-of select = "$title" />
  </a>
 </xsl:template>

<!-- ====================================================================== -->
<!-- template : Recipes                                                     -->
<!-- ====================================================================== -->

 <xsl:template name = "Recipe">
  <div class = "listitem">
  <xsl:call-template name = "Title">
   <xsl:with-param name = "type">file</xsl:with-param>
  </xsl:call-template>

  <xsl:if test = "abstract != ''">
   <div class = "abstract">
    <xsl:value-of select = "./abstract" />
   </div>
  </xsl:if>
  </div>
 </xsl:template>

<!-- ====================================================================== -->
<!-- template: Unknown                                                      -->
<!-- ====================================================================== -->

 <xsl:template name = "Unknown">
  <div class = "listitem">
   <!-- Need to test for README, HEADER & FOOTER -ness -->
   <img src = "/icons/generic.gif" />&#160;
   <a>
    <xsl:attribute name = "href">./<xsl:value-of select = "@id" /></xsl:attribute>
    <xsl:value-of select = "./@id" />
   </a>
   <xsl:if test = "error">
    <div style = "padding-left:30px;padding-top:5px;font-size:8pt;color:red;">
     <xsl:value-of select = "./error" />
    </div>
   </xsl:if>
  </div>   
 </xsl:template>

<!-- ====================================================================== -->
<!-- template : Styles                                                      -->
<!-- ====================================================================== -->

 <xsl:template name = "Styles">
  <style type = "text/css">
  //<![CDATA[
        foo {}

        body         {
                        margin-top:0px;
                        margin-bottom:0px;
                        margin-left:0px;
                        margin-right:0px; 
                        background-color:beige;
                        font-family:sans-serif;
                        font-size:11px;
                     }

        a            { 
                        text-decoration:none; 
                     }         

        a:hover      { 
                        text-decoration:none; 
                        color:orange; 
                     }               

        .breadcrumbs {
                        padding:10px;
                        font-size : 200%;
                        color : #adadad;
                        background-color:beige;
                     }

        .main        {
                        clear:left;
                        border-top:1px solid #adadad;
                        background-color:#ffffff;
                        padding-top:10px;
                        padding-left:10px;
                        padding-right:10px;
                        padding-bottom:500px;   
                     }

        .directory   { 
                      }

        .abstract    {
                        text-indent : 0px;
                        padding-left:60px;
                        padding-right:50px;
                        padding-top:5px;
                     }
        
        .file        { 
                        color:brown; 
                        margin-top:10x; 
                     }

        .listitem    {
                        border-left:1px solid beige;
                        border-top:1px solid beige;
                        padding-left:5px;
                        padding-top:5px;
                        margin-bottom:10px;
                     }
  //]]>
  </style>     
 </xsl:template>

 <!-- FIN -->
        
</xsl:stylesheet>

<!-- ====================================================================== -->
<!-- To do                                                                  -->
<!--                                                                        -->
<!-- * Proper documentation                                                 -->
<!--                                                                        -->
<!-- * Add hooks to pass CSS href via external parameter                    -->
<!--                                                                        -->
<!-- ====================================================================== -->

<!-- ====================================================================== -->
<!-- Changes                                                                -->
<!-- ====================================================================== -->


