<!-- ====================================================================== -->
<!-- eatdrinkfeelgood.xsl                                                   -->
<!--                                                                        -->
<!-- This stylesheet renders a recipe using Eatdrinkfeelgood markup         -->
<!-- language as an HTML document.                                          -->        
<!--                                                                        -->
<!-- Version : 0.2                                                          -->
<!-- Date    : October 07, 2001                                             -->
<!--                                                                        -->
<!-- Copyright (c) Aaron Straup Cope 2001                                   -->
<!--                                                                        --> 
<!-- This is free software, you may use it and distribute it under the same -->
<!-- terms as the Perl Artistic License.                                    -->
<!-- http://language.perl.com/misc/Artistic.html                            -->
<!--                                                                        --> 
<!-- ====================================================================== -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" />

<!-- ====================================================================== -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:variable name = "debug">0</xsl:variable>

<!-- ====================================================================== -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template match="/">
 <html>
  <head>
   <title><xsl:call-template name = "Title" /></title>
   <xsl:call-template name = "Styles" />
  </head>
  <body>
   <xsl:call-template name = "Main" />
  </body>
 </html>
</xsl:template>

<!-- ====================================================================== -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template match = "para">
 <xsl:call-template name = "Para" />
</xsl:template>

<!-- ====================================================================== -->
<!-- Main                                                                   -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Main">
 <div class = "main">
  <xsl:call-template name = "Header" />
   <xsl:choose>     
   <xsl:when test = "/eatdrinkfeelgood/menu">
     <xsl:for-each select = "eatdrinkfeelgood/menu">
      <xsl:call-template name = "Menu" />            
     </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
     <xsl:for-each select = "eatdrinkfeelgood/recipe">
      <xsl:call-template name = "Recipe" />      
     </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name = "Footer" />
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- Title                                                                  -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Title">  
 <xsl:choose>
  <xsl:when test = "/eatdrinkfeelgood/menu">
   <xsl:value-of select = "/eatdrinkfeelgood/menu/name/common" />           
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select = "/eatdrinkfeelgood/recipe/name/common" />
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Styles                                                                 -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Styles">
     <style type = "text/css">
       //<![CDATA[
        foo {}
        
        body               { margin-top:0px;margin-bottom:0px;margin-left:0px;margin-right:0px; } 
        p                  { margin-bottom:3px; margin-top:0; }

        .main              { padding:5px;margin:5px; }

       .header             { border:<xsl:value-of select = "$debug" />px solid blue;font-size:2em;padding:5px;margin:5px;  }
        .subheader         { border:<xsl:value-of select = "$debug" />px solid red;padding:5px;margin:5px;font-size:1.1em; }
        .footer            { }

        .menu              { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid pink; }
        .menu .header      { font-size:2em;margin-bottom:15px; }

        .courseset         { border:<xsl:value-of select = "$debug" />px solid green;padding:5px;margin:5px; }
        .course            { border:<xsl:value-of select = "$debug" />px solid aqua;padding:5px;margin:5px;background-color:#fffffe; }
        .course .header    { border:<xsl:value-of select = "$debug" />px solid blue;font-size:14pt;padding:5px;margin:5px; }
       
        .recipeset         { border:<xsl:value-of select = "$debug" />px solid gray;padding:5px;margin:5px; }
        .recipe            { border:<xsl:value-of select = "$debug" />px solid lime;padding:5px;margin:5px; }
        .recipe .header    { border:<xsl:value-of select = "$debug" />px solid blue;font-size:2em;margin:5px;padding:5px; }
        .recipe .header-sm { border:<xsl:value-of select = "$debug" />px solid blue;font-size:1.25em;margin:5px;padding:5px; }

        .sidebar           { float:right; background-color:#cccccc;width:250px;padding:15px;margin-bottom:5px;margin-left:5px;border:<xsl:value-of select = "$debug" />px solid #adadad; }
        .source            { color:#ffffff;font-size:9pt;border-bottom:1px solid #ffffff; }
        .categories        { color:#ffffff;font-size:9pt; padding-bottom:15px;}
        .history           { color:#666666;font-size:9pt;text-align:justify; }
        .history p         { text-indent:16pt; padding-bottom:5px;}

        .summary           { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid brown; }
        .abstract          { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid orange; }
        .abstract p        { text-indent : 8pt; }
        .items             { padding:5px;margin:5px; border:<xsl:value-of select = "$debug" />px solid yellow; }

        .ingredients       { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid violet; }
        .directions        { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid orange; }
        .step              { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid navy; } 
        .note              { padding:5px;margin:5px;border:<xsl:value-of select = "$debug" />px solid pink; }
        .note p            { text-indent : 8pt; }

        .meta              { font-size:8pt; text-indent:16pt;font-style:italic; }

        .revhistory        { border:<xsl:value-of select = "$debug" />px solid #cccccc;color:#adadad;padding:5px;margin:5px;font-size:8pt; }
    //]]>
     </style>
</xsl:template>

<!-- ====================================================================== -->
<!-- Header                                                                 -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Header">
 <div class = "header">
  <xsl:call-template name = "Title" />
 </div>  
</xsl:template>

<!-- ====================================================================== -->
<!-- Footer                                                                 -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Footer">
 <div class = "footer">
  <xsl:call-template name = "Revhistory" />
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- Menu                                                                   -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Menu">
 <div class = "menu">
  <xsl:call-template name = "MenuSummary" />
  <div class = "courseset">
   <xsl:for-each select = "course">
    <xsl:call-template name = "Course" />
   </xsl:for-each>
  </div>
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- MenuSummary                                                            -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "MenuSummary" >
 <div class = "summary">
  <xsl:for-each select = "abstract">   
   <xsl:call-template name = "Abstract" />
  </xsl:for-each>
  <div class = "items">
   <xsl:call-template name = "MenuCourses" />
  </div>
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- CourseSummary                                                          -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "CourseSummary" >
 <div class = "summary">
  <xsl:for-each select = "abstract">   
   <xsl:call-template name = "Abstract" />
  </xsl:for-each>
  <div class = "items">
   <xsl:call-template name = "CourseRecipes" />
   </div>
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- MenuCourses                                                            -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "MenuCourses">
  <div class = "menucourses">
  <ul>
  <xsl:for-each select = "course">
   <li><xsl:value-of select = "name/common" /></li>
  </xsl:for-each>
  </ul>
 </div>
</xsl:template>


<!-- ====================================================================== -->
<!-- Abstract                                                               -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Abstract">
 <div class = "abstract">
  <xsl:for-each select = "./para">
   <xsl:call-template name = "Para" />
  </xsl:for-each>
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- Course                                                                 -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Course">
 <div class = "course">
  <div class = "header">
   <xsl:value-of select = "name/common" />
  </div>
  <xsl:call-template name = "CourseSummary" />
  <div class = "recipeset">
   <xsl:for-each select = "recipe">
    <xsl:call-template name = "Recipe" />
   </xsl:for-each>
  </div>
 </div>   
</xsl:template>

<!-- ====================================================================== -->
<!-- CourseRecipes                                                          -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "CourseRecipes">
 <div class = "courserecipes">
  <ul>
  <xsl:for-each select = "recipe">
   <li><xsl:value-of select = "name/common" /></li>
  </xsl:for-each>
  </ul>
 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- Recipe                                                                 -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Recipe">
 <div class = "recipe">
  <xsl:if test = "/eatdrinkfeelgood/menu">
   <div class = "header-sm">
    <xsl:value-of select = "name/common" />
   </div>
  </xsl:if>
  <div class = "sidebar">
   <xsl:if test = "string(source/@content)">
    <div class = "source"><xsl:value-of select = "source/@content" /></div>  
   </xsl:if>
   <div class = "categories">
    <xsl:for-each select = "category">
     <xsl:value-of select = "@content" /><br />
    </xsl:for-each>
    <xsl:for-each select = "custom">
     <xsl:value-of select = "@name" />&#160;<xsl:value-of select = "@content" /><br />
    </xsl:for-each>    
   </div>
   <xsl:if test = "history/para">    
    <div class = "history">
     <xsl:for-each select = "history/para">
       <xsl:call-template name = "Para" />
     </xsl:for-each>
     <div class = "meta">
      <xsl:value-of select = "history/author" />
      <xsl:if test = "history/date">&#160;(<xsl:value-of select = "history/date" />)</xsl:if>
     </div>      
    </div>
   </xsl:if>
  </div>

  <div class = "ingredients">
  <div class = "subheader">
   Ingredients
  </div>

  <ul>
  <xsl:for-each select = "ingredients/ing">
   <li>
    <xsl:if test = "string(amount)"><xsl:value-of select = "amount" />&#160;</xsl:if>
    <xsl:choose>
     <xsl:when test = "measure/unit">
      <xsl:value-of select = "measure/unit/@content" />&#160;
     </xsl:when>        
     <xsl:otherwise>
       <xsl:if test = "string(measure/customunit)"><xsl:value-of select = "measure/customunit" />&#160;</xsl:if>       
     </xsl:otherwise>
    </xsl:choose>
    <xsl:if test = "string(item)"><xsl:value-of select = "item" /></xsl:if>
    <xsl:if test = "string(detail)">,&#160;<em><xsl:value-of select = "detail" /></em></xsl:if>
   </li>    
  </xsl:for-each>
  </ul>
  </div>

  <div class = "directions">
  <div class = "subheader">Directions</div>
   <ol>
    <xsl:for-each select = "directions/step">
     <li><xsl:apply-templates /></li>      
    </xsl:for-each>
   </ol>
  </div>

  <div class = "notes">
   <xsl:if test = "notes/note">
  <div class = "subheader">Notes</div>

  <xsl:for-each select = "notes/note">
   <div class = "note">
   <xsl:for-each select = "para">
     <xsl:call-template name = "Para" />
   </xsl:for-each>  
    <div class = "meta">
     <xsl:value-of select = "author" />
     <xsl:if test = "date">&#160;(<xsl:value-of select = "date" />)</xsl:if>
    </div>      
   </div>
  </xsl:for-each>
  </xsl:if>
 </div>

 </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- Revhistory                                                             -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Revhistory">
 <div class = "revhistory">
    <xsl:for-each select = "/eatdrinkfeelgood/revhistory/rev">
     <div>
      <xsl:value-of select = "version" />&#160;
      <xsl:for-each select = "changes/para"><xsl:value-of select = "." />&#160;</xsl:for-each>
      <em>
       <xsl:value-of select = "author/firstname" />&#160;<xsl:value-of select = "author/surname" />
        (<xsl:value-of select = "date/year" />/
        <xsl:value-of select = "date/month" />/
         <xsl:value-of select = "date/day" />)
      </em>
     </div>
    </xsl:for-each>
  </div>
</xsl:template>

<!-- ====================================================================== -->
<!-- Para                                                                   -->
<!--                                                                        -->
<!-- ====================================================================== -->

<xsl:template name = "Para">
 <p><xsl:value-of select = "." /></p>
</xsl:template>

<!-- ====================================================================== -->
<!-- FIN.                                                                   -->
<!-- ====================================================================== -->

</xsl:stylesheet>
